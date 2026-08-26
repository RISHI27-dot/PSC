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
MIX_DIR           = SCRIPT_DIR / 'MIX'
DIRS              = [IR_DIR, RGB_DIR, MIX_DIR]
RAW2BMP_SCRIPT    = SCRIPT_DIR / 'raw2bmp.py'
EXTRACT_SCRIPT    = SCRIPT_DIR / 'extract_embedded_mipi.py'
CLASSIFY_SCRIPT   = SCRIPT_DIR / 'classify_frames.py'
NB_REGS = 9
WIDTH = 1600
HEIGHT = 1040
BPP = 16

def process_bin_files():
    """Process all ir_*.bin and rgb_*.bin files from the frames directory into IR/ or RGB/"""
    if not FRAMES_DIR.exists():
        print(f"Error: frames directory does not exist: {FRAMES_DIR}")
        return

    bin_files = sorted(FRAMES_DIR.glob('*.bin'))

    if not bin_files:
        print(f"No ir_*.bin / rgb_*.bin files found in {FRAMES_DIR}")
        return

    # Ensure output directories exist
    IR_DIR.mkdir(exist_ok=True)
    RGB_DIR.mkdir(exist_ok=True)
    MIX_DIR.mkdir(exist_ok=True)

    print(f"\nProcessing {len(bin_files)} files from {FRAMES_DIR}...")

    for bin_file in bin_files:
        base_name = bin_file.stem  # e.g. ir_000 or rgb_000

        if base_name.startswith('ir_'):
            out_dir = IR_DIR
        elif base_name.startswith('rgb_'):
            out_dir = RGB_DIR
        else:
            out_dir = MIX_DIR

        bin_path = str(bin_file)
        bmp_src = FRAMES_DIR / f"{base_name}.bmp"  # raw2bmp writes here
        bmp_dst = out_dir / f"{base_name}.bmp"
        txt_path = out_dir / f"{base_name}.txt"

        if base_name.startswith('orgb_ir_60fsp-'):
            # Run raw2bmp.py only
            try:
                subprocess.run(
                    ['python3', str(RAW2BMP_SCRIPT), bin_path, str(WIDTH), str(HEIGHT), str(BPP)],
                    check=True,
                    capture_output=True,
                    text=True
                )
                bmp_src.rename(bmp_dst)
                print(f"  ✓ {bin_file.name} -> {bmp_dst.name}")
            except subprocess.CalledProcessError as e:
                print(f"  ✗ BMP error for {bin_file.name}: {e.stderr.strip()}")

        elif base_name.startswith('ov2312-emb-frame-'):
            # Run extract_embedded_mipi.py only
            try:
                result = subprocess.run(
                    ['python3', str(EXTRACT_SCRIPT), bin_path, str(NB_REGS)],
                    check=True,
                    capture_output=True,
                    text=True
                )
                with open(txt_path, 'w') as f:
                    f.write(result.stdout)
                print(f"  ✓ {bin_file.name} -> {txt_path.name}")
            except subprocess.CalledProcessError as e:
                print(f"  ✗ Embedded data error for {bin_file.name}: {e.stderr.strip()}")

        else:
            print(f"  ? Skipping unrecognised file: {bin_file.name}")

def classify():
    print("\nRunning frame classification...")
    try:
        subprocess.run(
            ['python3', str(CLASSIFY_SCRIPT)],
            check=True,
            text=True
        )
    except subprocess.CalledProcessError as e:
        print(f"  ✗ Classification error: {e}")

if __name__ == '__main__':
    process_bin_files()
    classify()
    print("\n✓ Batch processing complete!")
