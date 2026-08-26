#!/usr/bin/env python3

import re
import shutil
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent.resolve()
MIX_DIR    = SCRIPT_DIR / 'MIX'
RGB_DIR    = MIX_DIR / 'rgb'
IR_DIR     = MIX_DIR / 'ir'
THRESHOLD  = 774

def parse_current_exposure(txt_path):
    """Return the decimal current-exposure value from a txt file, or None if not found."""
    text = txt_path.read_text()
    m = re.search(r'Current Exposure:\s+0x[0-9A-Fa-f]+\s+\((\d+)\)', text)
    return int(m.group(1)) if m else None

def main():
    RGB_DIR.mkdir(exist_ok=True)
    IR_DIR.mkdir(exist_ok=True)

    txt_files = sorted(MIX_DIR.glob('ov2312-emb-frame-*.txt'))
    if not txt_files:
        print(f"No ov2312-emb-frame-*.txt files found in {MIX_DIR}")
        return

    print(f"{'TXT file':<35} {'Exposure':>10}  {'Class':<5}  BMP file")
    print("-" * 80)

    for txt_path in txt_files:
        # Extract zero-padded index, e.g. "000007"
        m = re.search(r'ov2312-emb-frame-(\d+)', txt_path.stem)
        if not m:
            print(f"  ? Cannot parse index from {txt_path.name}, skipping")
            continue
        idx = m.group(1)

        exposure = parse_current_exposure(txt_path)
        if exposure is None:
            print(f"  ? No Current Exposure in {txt_path.name}, skipping")
            continue

        label    = 'RGB' if exposure > THRESHOLD else 'IR'
        dest_dir = RGB_DIR if label == 'RGB' else IR_DIR

        bmp_path = MIX_DIR / f"orgb_ir_60fsp-{idx}.bmp"

        print(f"  {txt_path.name:<33} {exposure:>10}  {label:<5}  {bmp_path.name}")

        # Copy txt
        shutil.copy2(str(txt_path), str(dest_dir / txt_path.name))

        # Copy bmp if it exists
        if bmp_path.exists():
            shutil.copy2(str(bmp_path), str(dest_dir / bmp_path.name))
        else:
            print(f"    ! BMP not found: {bmp_path.name}")

    print("-" * 80)
    print(f"\nFiles copied to:")
    print(f"  RGB -> {RGB_DIR}")
    print(f"  IR  -> {IR_DIR}")

if __name__ == '__main__':
    main()
