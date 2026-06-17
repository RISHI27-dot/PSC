#!/usr/bin/env python3

import os
import subprocess
import sys
import tarfile
from pathlib import Path

# Configuration
SCRIPT_DIR        = Path(__file__).parent.resolve()
FRAMES_DIR        = SCRIPT_DIR / 'frames'
IR_DIR            = SCRIPT_DIR / 'IR'
RGB_DIR           = SCRIPT_DIR / 'RGB'
DIRS              = [IR_DIR, RGB_DIR]
RAW2BMP_SCRIPT    = SCRIPT_DIR / 'raw2bmp.py'
EXTRACT_SCRIPT    = SCRIPT_DIR / 'extract_embedded.py'
NB_REGS = 9
WIDTH = 1600
HEIGHT = 1300
BPP = 16

def extract_tar_files():
    """Extract tar.gz files in both directories"""
    for dir_path in DIRS:
        if not dir_path.exists():
            print(f"Warning: Directory does not exist: {dir_path}")
            continue

        tar_files = list(dir_path.glob('*.tar.gz'))

        if not tar_files:
            print(f"No .tar.gz files found in {dir_path}")
            continue

        print(f"\nExtracting tar files in {dir_path}...")

        for tar_file in tar_files:
            try:
                print(f"  → Extracting: {tar_file.name}")
                with tarfile.open(tar_file, 'r:gz') as tar:
                    tar.extractall(path=dir_path)
                print(f"    ✓ Extracted: {tar_file.name}")
            except Exception as e:
                print(f"    ✗ Error extracting {tar_file.name}: {e}")
                continue

def process_bin_files():
    """Process all .bin files from the frames directory into IR/ or RGB/"""
    if not FRAMES_DIR.exists():
        print(f"Error: frames directory does not exist: {FRAMES_DIR}")
        return

    bin_files = sorted(FRAMES_DIR.glob('*.bin'))

    if not bin_files:
        print(f"No .bin files found in {FRAMES_DIR}")
        return

    # Ensure output directories exist
    IR_DIR.mkdir(exist_ok=True)
    RGB_DIR.mkdir(exist_ok=True)

    print(f"\nProcessing {len(bin_files)} files from {FRAMES_DIR}...")

    for bin_file in bin_files:
        base_name = bin_file.stem  # e.g. ir_000 or rgb_000

        if base_name.startswith('ir_'):
            out_dir = IR_DIR
        elif base_name.startswith('rgb_'):
            out_dir = RGB_DIR
        else:
            print(f"  ✗ Skipping unrecognised file: {bin_file.name}")
            continue

        bin_path = str(bin_file)
        bmp_src = FRAMES_DIR / f"{base_name}.bmp"  # raw2bmp writes here
        bmp_dst = out_dir / f"{base_name}.bmp"
        txt_path = out_dir / f"{base_name}.txt"

        # Run raw2bmp.py (writes bmp next to the input file)
        try:
            subprocess.run(
                ['python3', str(RAW2BMP_SCRIPT), bin_path, str(WIDTH), str(HEIGHT), str(BPP)],
                check=True,
                capture_output=True,
                text=True
            )
            bmp_src.rename(bmp_dst)
        except subprocess.CalledProcessError as e:
            print(f"  ✗ BMP error for {bin_file.name}: {e.stderr}")
            continue

        # Run extract_embedded.py and write stdout to txt file
        try:
            result = subprocess.run(
                ['python3', str(EXTRACT_SCRIPT), bin_path, str(NB_REGS)],
                check=True,
                capture_output=True,
                text=True
            )
            with open(txt_path, 'w') as f:
                f.write(result.stdout)
        except subprocess.CalledProcessError as e:
            print(f"  ✗ Embedded data error for {bin_file.name}: {e.stderr}")
            continue

if __name__ == '__main__':
    #extract_tar_files()
    process_bin_files()
    print("\n✓ Batch processing complete!")
