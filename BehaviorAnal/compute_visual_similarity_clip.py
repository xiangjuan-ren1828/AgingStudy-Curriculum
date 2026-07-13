"""
Compute CLIP visual similarity among the 8 experiment images.

CLIP (Radford et al., 2021) is a Vision-Language model trained by OpenAI to
align image and text representations. The image encoder (ViT) produces a global
embedding that captures rich visual and semantic content.

Similarity is measured as cosine similarity between image embeddings.
Range: -1 (opposite) to 1 (identical); in practice 0–1 for natural images.

Images: car, female, hat, sunflower, castle, cat, key, cream
Expected: ImageSet/{label}.png  (relative to this script, or set IMAGE_DIR below)
Output: 8x8 similarity matrix printed as a table, pairwise ranking, and MATLAB format.

Comparison with DINOv2:
  - CLIP embeddings capture both visual AND semantic content (trained on image-text pairs).
  - DINOv2 embeddings are purely vision-driven (self-supervised on images only).
  - CLIP similarities may partly reflect semantic relatedness; DINOv2 is closer to
    pure visual appearance.

Requirements:
    pip install torch torchvision transformers Pillow numpy matplotlib scipy
    # GPU optional but recommended; script auto-detects CUDA / MPS / CPU
"""

import os
import sys
import numpy as np
import torch
import scipy.io
import matplotlib.pyplot as plt
from PIL import Image
from transformers import CLIPProcessor, CLIPVisionModelWithProjection

# ── Configuration ──────────────────────────────────────────────────────────────
LABELS = ['car', 'castle', 'cat', 'cream', 'female', 'hat', 'key', 'sunflower']

# Directory containing {label}.png files. Can be absolute or relative to CWD.
IMAGE_DIR = os.path.join(os.path.dirname(__file__), '..', 'ImageSet')

# Alternatives: openai/clip-vit-large-patch14  (stronger, ~300 MB more)
MODEL_NAME = 'openai/clip-vit-base-patch32'


# ── Device selection ──────────────────────────────────────────────────────────
def get_device():
    if torch.cuda.is_available():
        return torch.device('cuda')
    if torch.backends.mps.is_available():
        return torch.device('mps')
    return torch.device('cpu')


# ── Embedding extraction ──────────────────────────────────────────────────────
def load_model(model_name: str, device: torch.device):
    processor = CLIPProcessor.from_pretrained(model_name)
    model = CLIPVisionModelWithProjection.from_pretrained(model_name).to(device)
    model.eval()
    return processor, model


def extract_embeddings(labels, image_dir, processor, model, device):
    """Return (n_labels, hidden_dim) float32 numpy array of CLIP image embeddings."""
    embeddings = []
    for label in labels:
        img_path = os.path.join(image_dir, f'{label}.png')
        if not os.path.isfile(img_path):
            for ext in ('.jpg', '.jpeg', '.bmp'):
                alt = os.path.join(image_dir, f'{label}{ext}')
                if os.path.isfile(alt):
                    img_path = alt
                    break
            else:
                print(f"  [ERROR] Image not found: {img_path}", file=sys.stderr)
                sys.exit(1)

        image = Image.open(img_path).convert('RGB')
        inputs = processor(images=image, return_tensors='pt')
        inputs = {k: v.to(device) for k, v in inputs.items()}

        with torch.no_grad():
            outputs = model(pixel_values=inputs['pixel_values'])

        emb = outputs.image_embeds.squeeze(0).cpu().float().numpy()
        embeddings.append(emb)
        print(f"  Embedded: {label:12s}  (dim={emb.shape[0]})")

    return np.stack(embeddings)   # (n, d)


# ── Similarity matrix ─────────────────────────────────────────────────────────
def cosine_similarity_matrix(embeddings):
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    normed = embeddings / (norms + 1e-12)
    return normed @ normed.T   # (n, n), diagonal = 1.0


# ── Printing helpers ──────────────────────────────────────────────────────────
def print_table(mat, labels):
    col_w = 12
    header = f"{'':12s}" + "".join(f"{lbl:{col_w}s}" for lbl in labels)
    print(header)
    for i, lbl in enumerate(labels):
        row = f"{lbl:12s}" + "".join(f"{mat[i, j]:{col_w}.4f}" for j in range(len(labels)))
        print(row)


def print_pairwise(mat, labels):
    pairs = []
    n = len(labels)
    for i in range(n):
        for j in range(i + 1, n):
            pairs.append((labels[i], labels[j], mat[i, j]))
    pairs.sort(key=lambda x: -x[2])
    for a, b, s in pairs:
        print(f"  {a:12s} – {b:12s}: {s:.4f}")


def print_per_image_ranking(mat, labels):
    n = len(labels)
    for i, li in enumerate(labels):
        neighbors = sorted(
            [(mat[i, j], labels[j]) for j in range(n) if j != i],
            reverse=True
        )
        ranked = "  ".join(f"{lbl}({s:.3f})" for s, lbl in neighbors)
        print(f"  {li:12s}: {ranked}")


def print_matlab(mat, labels):
    print("% MATLAB: 8x8 CLIP cosine visual similarity matrix")
    print("% Row/column order: " + "  ".join(f"{lbl}={i+1}" for i, lbl in enumerate(labels)))
    print("clipSimMat = [")
    for i in range(len(labels)):
        row = "  " + "  ".join(f"{mat[i, j]:.4f}" for j in range(len(labels))) + ";"
        print(row)
    print("];")


# ── Visualization ─────────────────────────────────────────────────────────────
def baseline_correct(mat):
    """Subtract the mean off-diagonal similarity (baseline) from all off-diagonal cells."""
    n = mat.shape[0]
    mask = ~np.eye(n, dtype=bool)
    baseline = mat[mask].mean()
    corrected = mat.copy()
    corrected[mask] -= baseline
    np.fill_diagonal(corrected, np.nan)   # mask diagonal so it doesn't distort colorscale
    return corrected, baseline


def _draw_heatmap(ax, mat, labels, cmap, vmin, vmax, cbar_label):
    im = ax.imshow(mat, vmin=vmin, vmax=vmax, cmap=cmap)
    cbar = ax.figure.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label(cbar_label, fontsize=11)
    ax.set_xticks(range(len(labels)))
    ax.set_yticks(range(len(labels)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=11)
    ax.set_yticklabels(labels, fontsize=11)
    for i in range(len(labels)):
        for j in range(len(labels)):
            val = mat[i, j]
            if np.isnan(val):
                continue
            color = 'black' if vmin + 0.35 * (vmax - vmin) < val < vmin + 0.85 * (vmax - vmin) else 'white'
            ax.text(j, i, f'{val:.2f}', ha='center', va='center', fontsize=9, color=color)


def plot_similarity_matrix(mat, labels, out_dir):
    fig, ax = plt.subplots(figsize=(7, 6))
    _draw_heatmap(ax, mat, labels, cmap='RdYlGn', vmin=0, vmax=1,
                  cbar_label='Cosine similarity')
    ax.set_title(f'CLIP visual similarity ({MODEL_NAME})', fontsize=12, pad=12)
    fig.tight_layout()
    save_path = os.path.join(out_dir, 'clip_visual_similarity.png')
    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"  Saved .png : {save_path}")
    plt.show()


def plot_corrected_similarity_matrix(mat_corrected, baseline, labels, out_dir):
    fig, ax = plt.subplots(figsize=(7, 6))
    abs_max = np.nanmax(np.abs(mat_corrected))
    _draw_heatmap(ax, mat_corrected, labels, cmap='RdBu_r', vmin=-abs_max, vmax=abs_max,
                  cbar_label='Cosine similarity − baseline')
    ax.set_title(f'CLIP baseline-corrected similarity\n(baseline = {baseline:.4f})',
                 fontsize=12, pad=12)
    fig.tight_layout()
    save_path = os.path.join(out_dir, 'clip_visual_similarity_corrected.png')
    fig.savefig(save_path, dpi=150, bbox_inches='tight')
    print(f"  Saved .png : {save_path}")
    plt.show()


# ── Save results ──────────────────────────────────────────────────────────────
def save_results(mat, embeddings, labels, out_dir):
    os.makedirs(out_dir, exist_ok=True)

    npy_path = os.path.join(out_dir, 'clip_visual_similarity.npy')
    np.save(npy_path, mat)
    print(f"  Saved .npy : {npy_path}")

    emb_path = os.path.join(out_dir, 'clip_embeddings.npy')
    np.save(emb_path, embeddings)
    print(f"  Saved .npy : {emb_path}")

    mat_path = os.path.join(out_dir, 'clip_visual_similarity.mat')
    scipy.io.savemat(mat_path, {
        'clipSimMat':  mat,
        'embeddings':  embeddings,
        'labels':      np.array(labels, dtype=object),
    })
    print(f"  Saved .mat : {mat_path}")


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    image_dir = os.path.abspath(IMAGE_DIR)
    print(f"=== CLIP visual similarity  ({MODEL_NAME}) ===")
    print(f"Image directory : {image_dir}")
    if not os.path.isdir(image_dir):
        print(f"[ERROR] Image directory not found: {image_dir}", file=sys.stderr)
        print("Set IMAGE_DIR at the top of this script to point to your stimulus folder.",
              file=sys.stderr)
        sys.exit(1)

    device = get_device()
    print(f"Device          : {device}\n")

    print("Loading CLIP model…")
    processor, model = load_model(MODEL_NAME, device)

    print("\nExtracting embeddings…")
    embeddings = extract_embeddings(LABELS, image_dir, processor, model, device)

    mat = cosine_similarity_matrix(embeddings)
    np.fill_diagonal(mat, 1.0)

    print("\n=== CLIP cosine similarity matrix ===")
    print_table(mat, LABELS)

    off_diag = [mat[i, j] for i in range(len(LABELS)) for j in range(len(LABELS)) if i != j]
    print(f"\nOff-diagonal: min={min(off_diag):.4f}  max={max(off_diag):.4f}  "
          f"mean={np.mean(off_diag):.4f}  median={np.median(off_diag):.4f}")

    print("\n=== Pairwise similarities (high → low) ===")
    print_pairwise(mat, LABELS)

    print("\n=== Per-image similarity ranking ===")
    print_per_image_ranking(mat, LABELS)

    print("\n=== MATLAB format ===")
    print_matlab(mat, LABELS)

    out_dir = os.path.join(os.path.dirname(__file__), 'clip_results')
    print("\n=== Saving results ===")
    save_results(mat, embeddings, LABELS, out_dir)
    plot_similarity_matrix(mat, LABELS, out_dir)

    mat_corrected, baseline = baseline_correct(mat)
    print(f"\nBaseline (mean off-diagonal): {baseline:.4f}")

    corr_npy = os.path.join(out_dir, 'clip_visual_similarity_corrected.npy')
    np.save(corr_npy, mat_corrected)
    print(f"  Saved .npy : {corr_npy}")

    corr_mat = os.path.join(out_dir, 'clip_visual_similarity_corrected.mat')
    scipy.io.savemat(corr_mat, {
        'clipSimMat_corrected': mat_corrected,
        'baseline':             baseline,
        'labels':               np.array(LABELS, dtype=object),
    })
    print(f"  Saved .mat : {corr_mat}")

    plot_corrected_similarity_matrix(mat_corrected, baseline, LABELS, out_dir)
