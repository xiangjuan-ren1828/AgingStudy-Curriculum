"""
episodic_memory_net.py
======================
Neural network that performs the same sequential episodic memory task
as human participants in the AgingReplay experiment, with three retrieval types.

Task structure (matches EpisodicMemoryTask-contentBlocked.js)
-------------------------------------------------------------
  Study phase    : see N_TRANS=5 (image, position) pairs presented in order 1→5
  Content retr.  : 6 shuffled images shown; click each in study order (distractor last)
  Location retr. : 6 shuffled positions shown; click each in study order
  Reconstruction : 6 shuffled images + 6 shuffled target slots; drag each image
                   to its correct slot — requires BOTH content AND location binding

Design principles
-----------------
  Content retrieval   — requires image identity ↔ temporal order binding
  Location retrieval  — requires position ↔ temporal order binding
  Reconstruction      — requires image ↔ position binding (content + location joint)

  The three retrievals share one study encoder but have separate retrieval heads,
  mirroring how human episodic memory supports multiple retrieval routes from
  the same underlying episode representation.

Architecture
------------
  Study encoder      : Transformer encoder over N_TRANS (img + pos + step) tokens
  Retrieval decoder  : Cross-attention — probe tokens attend to study memory
  Content head       : Linear → N_TRANS+1 classes  (orders 0..4, dtr=5)
  Location head      : Linear → N_TRANS+1 classes
  Reconstruction head: Linear → N_ITEMS+1 classes  (slot indices 0..5, dtr=6)

  For reconstruction, the study memory is extended with the displayed slot position
  tokens so the network can map: image → study order → matching slot index.
  This is the only retrieval type that requires three-way binding.
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
import numpy as np
import matplotlib.pyplot as plt

# ── Task parameters (matching the PsychoPy experiment) ────────────────────────
N_IMG   = 8          # pool of unique images
N_POS   = 8          # pool of unique positions on the circle
N_TRANS = 5          # sequence length
N_DTR   = 1          # distractors per episode
N_ITEMS = N_TRANS + N_DTR   # 6 items shown per retrieval screen

# Distractor sentinel labels
DTR_LABEL_CON  = N_TRANS   # = 5  (used for content and location)
DTR_LABEL_BOTH = N_ITEMS   # = 6  (used for reconstruction)

# ── Model hyperparameters ──────────────────────────────────────────────────────
D_MODEL      = 64
N_HEADS      = 4
N_ENC_LAYERS = 2    # study encoder depth
N_DEC_LAYERS = 2    # retrieval decoder depth
DROPOUT      = 0.1

# ── Training hyperparameters ───────────────────────────────────────────────────
N_TRAIN    = 100_000
N_VAL      = 5_000
BATCH_SIZE = 256
N_EPOCHS   = 50
LR         = 1e-3

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


# ══════════════════════════════════════════════════════════════════════════════
# 1.  DATASET
# ══════════════════════════════════════════════════════════════════════════════

class EpisodicMemoryDataset(Dataset):
    """
    Generates synthetic episodes that mirror the PsychoPy task structure.

    Each episode:
      - Samples N_ITEMS unique images and positions from their respective pools.
      - The first N_TRANS (image, position) pairs form the study sequence
        (presented in study order 0 → N_TRANS-1); the last pair is the distractor.
      - Generates shuffled query arrays and ground-truth labels for all three
        retrieval types.

    Label conventions
    -----------------
      Content / Location : 0..N_TRANS-1 = study order; N_TRANS   = distractor
      Reconstruction     : 0..N_ITEMS-1 = slot index;  N_ITEMS   = distractor
    """

    def __init__(self, n_episodes: int, seed: int | None = None):
        self.n   = n_episodes
        self.rng = np.random.default_rng(seed)

    def __len__(self):
        return self.n

    def __getitem__(self, _):
        rng = self.rng

        # Sample N_ITEMS unique images and positions
        imgs = rng.choice(N_IMG, N_ITEMS, replace=False)
        poss = rng.choice(N_POS, N_ITEMS, replace=False)

        seq_imgs, dtr_img = imgs[:N_TRANS], int(imgs[N_TRANS])
        seq_poss, dtr_pos = poss[:N_TRANS], int(poss[N_TRANS])

        all_imgs = np.append(seq_imgs, dtr_img)   # [N_ITEMS]
        all_poss = np.append(seq_poss, dtr_pos)   # [N_ITEMS]

        # Lookup tables: item → study order (0-indexed)
        img2ord = {int(img): k for k, img in enumerate(seq_imgs)}
        img2ord[dtr_img] = DTR_LABEL_CON

        pos2ord = {int(pos): k for k, pos in enumerate(seq_poss)}
        pos2ord[dtr_pos] = DTR_LABEL_CON

        # ── Content retrieval ──────────────────────────────────────────────────
        # Probe: N_ITEMS shuffled images.  Label: study order of each image.
        con_perm  = rng.permutation(N_ITEMS)
        con_query = all_imgs[con_perm]
        con_label = np.array([img2ord[int(i)] for i in con_query])

        # ── Location retrieval ─────────────────────────────────────────────────
        # Probe: N_ITEMS shuffled positions.  Label: study order of each position.
        loc_perm  = rng.permutation(N_ITEMS)
        loc_query = all_poss[loc_perm]
        loc_label = np.array([pos2ord[int(p)] for p in loc_query])

        # ── Reconstruction ─────────────────────────────────────────────────────
        # Probe: N_ITEMS shuffled images.
        # Context: N_ITEMS shuffled target slot positions (displayed on screen).
        # Label: for each image, the index in the slot array where it belongs.
        #   → requires knowing image identity (content) AND which position it was
        #     shown at (location) to find the matching slot index.
        img_perm   = rng.permutation(N_ITEMS)
        slot_perm  = rng.permutation(N_ITEMS)
        both_imgs  = all_imgs[img_perm]
        both_slots = all_poss[slot_perm]   # displayed slot positions (shuffled)

        pos2slotidx = {int(pos): int(idx) for idx, pos in enumerate(both_slots)}
        pos2slotidx[dtr_pos] = DTR_LABEL_BOTH   # distractor has no valid slot

        img2slotidx = {int(seq_imgs[k]): pos2slotidx[int(seq_poss[k])]
                       for k in range(N_TRANS)}
        img2slotidx[dtr_img] = DTR_LABEL_BOTH

        both_label = np.array([img2slotidx[int(img)] for img in both_imgs])

        return dict(
            study_imgs  = torch.tensor(seq_imgs,   dtype=torch.long),   # [N_TRANS]
            study_poss  = torch.tensor(seq_poss,   dtype=torch.long),   # [N_TRANS]
            con_query   = torch.tensor(con_query,  dtype=torch.long),   # [N_ITEMS]
            con_label   = torch.tensor(con_label,  dtype=torch.long),   # [N_ITEMS]
            loc_query   = torch.tensor(loc_query,  dtype=torch.long),   # [N_ITEMS]
            loc_label   = torch.tensor(loc_label,  dtype=torch.long),   # [N_ITEMS]
            both_imgs   = torch.tensor(both_imgs,  dtype=torch.long),   # [N_ITEMS]
            both_slots  = torch.tensor(both_slots, dtype=torch.long),   # [N_ITEMS]
            both_label  = torch.tensor(both_label, dtype=torch.long),   # [N_ITEMS]
        )


# ══════════════════════════════════════════════════════════════════════════════
# 2.  MODEL
# ══════════════════════════════════════════════════════════════════════════════

class EpisodicMemoryNet(nn.Module):
    """
    Transformer-based episodic memory network.

    Study encoder
    -------------
    Encodes the ordered study sequence into memory tokens.
    Each token = img_emb(img) + pos_emb(pos) + step_emb(step), capturing
    the three-way (image, position, temporal order) binding for every study event.

    Retrieval decoder
    -----------------
    Cross-attention: probe tokens (query) attend to study memory (key/value).
    The retrieved representations are then classified by task-specific heads.

    Retrieval probes
    ----------------
      Content        : probe = img_emb(query_image)
                       memory = study memory
      Location       : probe = pos_emb(query_position)
                       memory = study memory
      Reconstruction : probe = img_emb(query_image)
                       memory = study memory ++ slot_emb(displayed_slots)
                       The slot tokens give the network access to which positions
                       are available, forcing it to bind image→order→slot.
    """

    def __init__(self):
        super().__init__()

        self.img_emb  = nn.Embedding(N_IMG,   D_MODEL)
        self.pos_emb  = nn.Embedding(N_POS,   D_MODEL)
        self.step_emb = nn.Embedding(N_TRANS, D_MODEL)   # study step 0..N_TRANS-1

        enc_layer = nn.TransformerEncoderLayer(
            d_model=D_MODEL, nhead=N_HEADS,
            dim_feedforward=D_MODEL * 4,
            dropout=DROPOUT, batch_first=True)
        self.study_encoder = nn.TransformerEncoder(enc_layer, num_layers=N_ENC_LAYERS)

        dec_layer = nn.TransformerDecoderLayer(
            d_model=D_MODEL, nhead=N_HEADS,
            dim_feedforward=D_MODEL * 4,
            dropout=DROPOUT, batch_first=True)
        self.retrieval_decoder = nn.TransformerDecoder(dec_layer, num_layers=N_DEC_LAYERS)

        n_cls_order = N_TRANS + 1   # 6: orders 0..4, distractor=5
        n_cls_slot  = N_ITEMS + 1   # 7: slot indices 0..5, distractor=6

        self.con_head  = nn.Linear(D_MODEL, n_cls_order)
        self.loc_head  = nn.Linear(D_MODEL, n_cls_order)
        self.both_head = nn.Linear(D_MODEL, n_cls_slot)

    def encode_study(self, study_imgs, study_poss):
        """Encode ordered study pairs into episodic memory. → [B, N_TRANS, D]"""
        B     = study_imgs.size(0)
        steps = torch.arange(N_TRANS, device=study_imgs.device).unsqueeze(0).expand(B, -1)
        tokens = (self.img_emb(study_imgs)
                  + self.pos_emb(study_poss)
                  + self.step_emb(steps))           # [B, N_TRANS, D]
        return self.study_encoder(tokens)

    def retrieve(self, memory, probe):
        """Cross-attend probe to memory. → [B, N_probe, D]"""
        return self.retrieval_decoder(probe, memory)

    def forward(self, batch):
        memory = self.encode_study(batch['study_imgs'], batch['study_poss'])

        # Content: probe = image identity only
        con_out    = self.retrieve(memory, self.img_emb(batch['con_query']))
        con_logits = self.con_head(con_out)                  # [B, N_ITEMS, N_TRANS+1]

        # Location: probe = position identity only
        loc_out    = self.retrieve(memory, self.pos_emb(batch['loc_query']))
        loc_logits = self.loc_head(loc_out)

        # Reconstruction: extend memory with displayed slot positions so the
        # network can resolve image → study order → matching slot index
        slot_tokens = self.pos_emb(batch['both_slots'])      # [B, N_ITEMS, D]
        mem_both    = torch.cat([memory, slot_tokens], dim=1) # [B, N_TRANS+N_ITEMS, D]
        both_out    = self.retrieve(mem_both, self.img_emb(batch['both_imgs']))
        both_logits = self.both_head(both_out)               # [B, N_ITEMS, N_ITEMS+1]

        return con_logits, loc_logits, both_logits


# ══════════════════════════════════════════════════════════════════════════════
# 3.  TRAINING UTILITIES
# ══════════════════════════════════════════════════════════════════════════════

def compute_loss(con_logits, loc_logits, both_logits, batch):
    """Equal-weight cross-entropy across all three retrieval heads."""
    def ce(logits, labels):
        B, N, C = logits.shape
        return F.cross_entropy(logits.reshape(B * N, C), labels.reshape(B * N))

    lc = ce(con_logits,  batch['con_label'])
    ll = ce(loc_logits,  batch['loc_label'])
    lb = ce(both_logits, batch['both_label'])
    return (lc + ll + lb) / 3.0, lc.item(), ll.item(), lb.item()


def item_accuracy(logits, labels, dtr_label):
    """Per-item accuracy, excluding distractor items."""
    preds = logits.argmax(dim=-1)
    mask  = labels != dtr_label
    if mask.sum() == 0:
        return float('nan')
    return (preds[mask] == labels[mask]).float().mean().item()


def run_epoch(model, loader, optimizer=None):
    training = optimizer is not None
    model.train(training)

    sums = dict(loss=0.0, lc=0.0, ll=0.0, lb=0.0,
                acc_con=0.0, acc_loc=0.0, acc_both=0.0, n=0)

    with torch.set_grad_enabled(training):
        for batch in loader:
            batch = {k: v.to(DEVICE) for k, v in batch.items()}
            con_l, loc_l, both_l = model(batch)
            loss, lc, ll, lb = compute_loss(con_l, loc_l, both_l, batch)

            if training:
                optimizer.zero_grad()
                loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()

            B = con_l.size(0)
            sums['loss'] += loss.item() * B
            sums['lc']   += lc * B
            sums['ll']   += ll * B
            sums['lb']   += lb * B
            sums['acc_con']  += item_accuracy(con_l,  batch['con_label'],  DTR_LABEL_CON)  * B
            sums['acc_loc']  += item_accuracy(loc_l,  batch['loc_label'],  DTR_LABEL_CON)  * B
            sums['acc_both'] += item_accuracy(both_l, batch['both_label'], DTR_LABEL_BOTH) * B
            sums['n'] += B

    n = sums['n']
    return {k: sums[k] / n for k in sums if k != 'n'}


# ══════════════════════════════════════════════════════════════════════════════
# 4.  MAIN TRAINING LOOP
# ══════════════════════════════════════════════════════════════════════════════

def train():
    train_ds = EpisodicMemoryDataset(N_TRAIN, seed=0)
    val_ds   = EpisodicMemoryDataset(N_VAL,   seed=99)
    train_dl = DataLoader(train_ds, batch_size=BATCH_SIZE, shuffle=True,  num_workers=0)
    val_dl   = DataLoader(val_ds,   batch_size=BATCH_SIZE, shuffle=False, num_workers=0)

    model     = EpisodicMemoryNet().to(DEVICE)
    optimizer = torch.optim.Adam(model.parameters(), lr=LR)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=N_EPOCHS)

    n_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"Device  : {DEVICE}")
    print(f"Params  : {n_params:,}")
    print(f"Task    : {N_TRANS} seq + {N_DTR} dtr  |  pool {N_IMG} imgs × {N_POS} pos")
    print()
    hdr = (f"{'Ep':>4}  {'TrLoss':>7} {'VaLoss':>7}  "
           f"{'TrCon':>6} {'VaCon':>6}  "
           f"{'TrLoc':>6} {'VaLoc':>6}  "
           f"{'TrBoth':>7} {'VaBoth':>7}")
    print(hdr)
    print('-' * len(hdr))

    history = {k: [] for k in
               ('tr_loss', 'va_loss',
                'tr_acc_con',  'va_acc_con',
                'tr_acc_loc',  'va_acc_loc',
                'tr_acc_both', 'va_acc_both')}

    for epoch in range(1, N_EPOCHS + 1):
        tr = run_epoch(model, train_dl, optimizer)
        va = run_epoch(model, val_dl)
        scheduler.step()

        history['tr_loss'].append(tr['loss'])
        history['va_loss'].append(va['loss'])
        for cond in ('con', 'loc', 'both'):
            history[f'tr_acc_{cond}'].append(tr[f'acc_{cond}'])
            history[f'va_acc_{cond}'].append(va[f'acc_{cond}'])

        print(f"{epoch:4d}  {tr['loss']:7.4f} {va['loss']:7.4f}  "
              f"{tr['acc_con']:6.3f} {va['acc_con']:6.3f}  "
              f"{tr['acc_loc']:6.3f} {va['acc_loc']:6.3f}  "
              f"{tr['acc_both']:7.3f} {va['acc_both']:7.3f}")

    return model, history


# ══════════════════════════════════════════════════════════════════════════════
# 5.  PLOTTING
# ══════════════════════════════════════════════════════════════════════════════

def plot_history(history):
    epochs = range(1, len(history['tr_loss']) + 1)
    colors = {'con': '#2B73C2', 'loc': '#E07B39', 'both': '#4CAF50'}
    labels = {'con': 'Content', 'loc': 'Location', 'both': 'Reconstruction'}
    chance = 1.0 / N_TRANS   # uniform over sequence items

    fig, axes = plt.subplots(1, 2, figsize=(13, 4.5))

    # Loss
    ax = axes[0]
    ax.plot(epochs, history['tr_loss'], '-',  color='k', label='Train')
    ax.plot(epochs, history['va_loss'], '--', color='k', label='Val')
    ax.set_xlabel('Epoch')
    ax.set_ylabel('Cross-entropy loss')
    ax.set_title('Training loss')
    ax.legend(frameon=False)
    ax.spines[['top', 'right']].set_visible(False)

    # Accuracy per retrieval type
    ax = axes[1]
    for cond in ('con', 'loc', 'both'):
        c = colors[cond]
        ax.plot(epochs, history[f'tr_acc_{cond}'], '-',  color=c,
                label=f'{labels[cond]} (train)')
        ax.plot(epochs, history[f'va_acc_{cond}'], '--', color=c,
                label=f'{labels[cond]} (val)', alpha=0.7)
    ax.axhline(chance, color='gray', linestyle=':', linewidth=1, label='Chance')
    ax.set_xlabel('Epoch')
    ax.set_ylabel('Accuracy (excl. distractor)')
    ax.set_title('Retrieval accuracy by type')
    ax.legend(fontsize=7, ncol=2, frameon=False)
    ax.spines[['top', 'right']].set_visible(False)

    plt.tight_layout()
    plt.savefig('training_history.png', dpi=150)
    plt.show()
    print('Saved → training_history.png')


# ══════════════════════════════════════════════════════════════════════════════
# 6.  ENTRY POINT
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    model, history = train()
    plot_history(history)
    torch.save(model.state_dict(), 'episodic_memory_net.pt')
    print('Saved → episodic_memory_net.pt')
