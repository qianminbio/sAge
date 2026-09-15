"""Create a small, deterministic reviewer subset from Heart.hdf5."""

import argparse
from pathlib import Path

import h5py
import numpy as np


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=Path('data/Heart.hdf5'))
    parser.add_argument('--output', type=Path, default=Path('data/Heart-reviewer-demo.h5'))
    parser.add_argument('--per-class', type=int, default=60)
    parser.add_argument('--seed', type=int, default=20201212)
    args = parser.parse_args()
    if args.per_class < 6:
        parser.error('--per-class must be at least 6 for five-fold validation.')
    if args.output.exists():
        parser.error(f'Output already exists: {args.output}')

    with h5py.File(args.source, 'r') as source:
        if source['data'].ndim != 2 or source['data'].shape[1] != 22919:
            parser.error('Expected data with 22,919 features.')
        labels = source['label'][:]
        if labels.ndim != 2 or labels.shape[1] < 2:
            parser.error('Expected class and covariate columns in label.')
        class_ids = np.unique(labels[:, 0])
        if class_ids.tolist() != [1, 4]:
            parser.error(f'Expected Heart class IDs [1, 4]; found {class_ids}.')
        generator = np.random.default_rng(args.seed)
        indices = np.sort(np.concatenate([
            generator.choice(np.flatnonzero(labels[:, 0] == class_id),
                             size=args.per_class, replace=False)
            for class_id in class_ids
        ]))
        data = source['data'][indices]
        subset_labels = labels[indices]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with h5py.File(args.output, 'w') as destination:
        destination.create_dataset('data', data=data, compression='gzip', shuffle=True)
        destination.create_dataset('label', data=subset_labels)
        destination.attrs['source'] = 'Heart.hdf5'
        destination.attrs['selection_seed'] = args.seed
        destination.attrs['cells_per_class'] = args.per_class
    print(f'Wrote {len(indices)} cells to {args.output} ({args.output.stat().st_size:,} bytes).')


if __name__ == '__main__':
    main()
