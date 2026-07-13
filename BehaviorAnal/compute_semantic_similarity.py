"""
Compute Wu-Palmer semantic similarity among the 8 experiment images using WordNet.

Wu-Palmer similarity (wup_similarity) measures how similar two concepts are based
on their depth in the WordNet noun taxonomy and their lowest common subsumer (LCS).
Range: 0 (no shared ancestor) to 1 (identical).

Images: car, female, hat, sunflower, castle, cat, key, cream
Output: 8x8 similarity matrix printed as a table and in MATLAB array format.

Requirements:
    pip install nltk
    python -c "import nltk; nltk.download('wordnet'); nltk.download('omw-1.4')"
"""

import numpy as np
import nltk
from nltk.corpus import wordnet as wn

# Download required WordNet data (safe to call even if already downloaded)
nltk.download('wordnet',  quiet=True)
nltk.download('omw-1.4', quiet=True)

# ── Image labels and WordNet synset selection ──────────────────────────────────
# For each image, choose the noun synset that best matches the visual concept.
# 'female' maps to female.n.02 (person) rather than female.n.01 (any organism).
# 'castle' maps to castle.n.02 (fortified building) rather than castle.n.01
#   (which WordNet resolves to palace.n.01, a large mansion).
# 'cream'  maps to cream.n.03 (skin lotion) rather than cream.n.01 (metaphorical
#   "the best") or cream.n.02 (butterfat).

LABELS = ['car', 'female', 'hat', 'sunflower', 'castle', 'cat', 'key', 'cream']

SYNSETS = {
    'car':      wn.synset('car.n.01'),        # motor vehicle
    'female':   wn.synset('female.n.02'),      # person who can have babies
    'hat':      wn.synset('hat.n.01'),         # headwear
    'sunflower': wn.synset('sunflower.n.01'),  # plant
    'castle':   wn.synset('castle.n.02'),      # fortified building
    'cat':      wn.synset('cat.n.01'),         # domestic feline
    'key':      wn.synset('key.n.01'),         # metal lock key
    'cream':    wn.synset('cream.n.03'),       # skin cream / lotion
}


def build_similarity_matrix(labels, synsets):
    n = len(labels)
    mat = np.zeros((n, n))
    for i, li in enumerate(labels):
        for j, lj in enumerate(labels):
            if i == j:
                mat[i, j] = 1.0
            else:
                sim = synsets[li].wup_similarity(synsets[lj])
                mat[i, j] = sim if sim is not None else 0.0
    return mat


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
    print("% MATLAB: 8x8 Wu-Palmer semantic similarity matrix")
    print("% Row/column order: " + "  ".join(f"{lbl}={i+1}" for i, lbl in enumerate(labels)))
    print("conSimMat = [")
    for i in range(len(labels)):
        row = "  " + "  ".join(f"{mat[i, j]:.4f}" for j in range(len(labels))) + ";"
        print(row)
    print("];")


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    # Verify synset selections
    print("=== Selected synsets ===")
    for lbl in LABELS:
        s = SYNSETS[lbl]
        print(f"  {lbl:12s} → {s}  [{s.definition()}]")

    mat = build_similarity_matrix(LABELS, SYNSETS)

    print("\n=== Wu-Palmer similarity matrix ===")
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
