"""Exercise data preparation and one training epoch using temporary synthetic data."""

from pathlib import Path
import subprocess
import sys
import tempfile

import h5py
import numpy as np


def main():
    repository = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix='sage-smoke-') as temporary:
        root = Path(temporary)
        source = root / 'synthetic.hdf5'
        rng = np.random.default_rng(17)
        with h5py.File(source, 'w') as stream:
            stream['data'] = rng.poisson(1, size=(72, 22919)).astype(np.float32)
            stream['label'] = np.column_stack([
                np.tile(np.arange(6), 12), np.zeros(72, dtype=int)])
        subprocess.run([
            sys.executable, str(repository / 'model/prepare_dataset_for_cv.py'),
            '--data_path', str(source), '--output_dir', str(root / 'prepared'),
        ], check=True, cwd=repository)
        result = subprocess.run([
            sys.executable, str(repository / 'run_cross_validation.py'),
            '--data-dir', str(root / 'prepared'),
            '--output-dir', str(root / 'results'), '--folds', '0', '--',
            '--numhead', '1', '--batchsize', '8', '--batchrepeat', '1',
            '--max_epochs', '1',
        ], cwd=repository)
        log_path = root / 'results/fold_0/train.log'
        log = log_path.read_text(encoding='utf-8') if log_path.exists() else ''
        if result.returncode:
            print(log)
            result.check_returncode()
        if '#Final Test:' not in log:
            raise RuntimeError('Training did not reach final evaluation.\n' + log)
    print('PASS: synthetic data preparation, one-fold training, and final evaluation.')
    print('Synthetic scores have no biological meaning; this is not manuscript reproduction.')


if __name__ == '__main__':
    main()
