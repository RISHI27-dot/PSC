#!/usr/bin/env python3

import os
import subprocess
import sys
import tarfile
from pathlib import Path

# Configuration
DIRS = ['RGB', 'IR']
NB_REGS = 9
WIDTH = 1600
HEIGHT = 1300
BPP = 16

def extract_tar_files():
    """Extract tar.gz files in both directories"""
    for directory in DIRS:
        dir_path = Path(directory)

        if not dir_path.exists():
            print(f"Warning: Directory {directory} does not exist")
            continue

        # Find all .tar.gz files in the directory
        tar_files = list(dir_path.glob('*.tar.gz'))

        if not tar_files:
            print(f"No .tar.gz files found in {directory}")
            continue

        print(f"\nExtracting tar files in {directory}...")

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
    """Process all .bin files in both directories"""
    for directory in DIRS:
        dir_path = Path(directory)

        if not dir_path.exists():
            print(f"Warning: Directory {directory} does not exist")
            continue

        # Find all .bin files in the directory
        bin_files = sorted(dir_path.glob('*.bin'))

        if not bin_files:
            print(f"No .bin files found in {directory}")
            continue

        print(f"\nProcessing {len(bin_files)} files in {directory}...")

        for bin_file in bin_files:
            bin_path = str(bin_file)
            base_name = bin_file.stem  # filename without extension

            # Generate output file paths
            bmp_path = bin_file.parent / f"{base_name}.bmp"
            txt_path = bin_file.parent / f"{base_name}.txt"

            # print(f"\nProcessing: {bin_path}")

            # Run raw2bmp.py
            try:
                # print(f"  → Converting to BMP: {bmp_path}")
                subprocess.run(
                    ['python3', 'raw2bmp.py', bin_path, str(WIDTH), str(HEIGHT), str(BPP)],
                    check=True,
                    capture_output=True,
                    text=True
                )
                # print(f"    ✓ BMP created: {bmp_path}")
            except subprocess.CalledProcessError as e:
                print(f"    ✗ Error converting to BMP: {e.stderr}")
                continue

            # Run extract_embedded.py and capture output to txt file
            try:
                # print(f"  → Extracting embedded data: {txt_path}")
                result = subprocess.run(
                    ['python3', 'extract_embedded.py', bin_path, str(NB_REGS)],
                    check=True,
                    capture_output=True,
                    text=True
                )

                # Write output to txt file
                with open(txt_path, 'w') as f:
                    f.write(result.stdout)

                # print(f"    ✓ Embedded data extracted: {txt_path}")
            except subprocess.CalledProcessError as e:
                print(f"    ✗ Error extracting embedded data: {e.stderr}")
                continue

if __name__ == '__main__':
    #extract_tar_files()
    process_bin_files()
    print("\n✓ Batch processing complete!")
