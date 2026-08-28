#!/usr/bin/env python3
"""
Extract embedded register data from MIPI-format .bin files.

MIPI format layout (vs raw10):
  - raw10: each 10-bit pixel value stored as (val << 2) in a 16-bit LE word
  - MIPI:  pixels are packed in MIPI RAW10 format (4 pixels per 5 bytes), and
           each packed byte is stored in the low byte of a 16-bit LE word

MIPI RAW10 packing (5 bytes -> 4 pixels):
  P0 = (B0 << 2) | (B4[1:0])
  P1 = (B1 << 2) | (B4[3:2])
  P2 = (B2 << 2) | (B4[5:4])
  P3 = (B3 << 2) | (B4[7:6])

Register entry structure (same as raw10, 6 pixels per register):
  [pad(0), reghi, skip(0), reglo, skip(0), val]
  reg_addr = (reghi << 8) | reglo
"""

import struct
import sys


def decode_mipi_raw10(file_bytes):
    """Decode MIPI RAW10 packed pixels from file bytes.

    Each 16-bit LE word in the file carries one MIPI packed byte in bits[7:0].
    Groups of 5 packed bytes encode 4 10-bit pixel values.
    """
    n_words = len(file_bytes) // 2
    packed = bytearray(
        struct.unpack('<H', file_bytes[i * 2: i * 2 + 2])[0] & 0xFF
        for i in range(n_words)
    )
    pixels = []
    for i in range(0, len(packed) - 4, 5):
        B0, B1, B2, B3, B4 = packed[i], packed[i+1], packed[i+2], packed[i+3], packed[i+4]
        pixels.append((B0 << 2) | (B4 & 0x03))
        pixels.append((B1 << 2) | ((B4 >> 2) & 0x03))
        pixels.append((B2 << 2) | ((B4 >> 4) & 0x03))
        pixels.append((B3 << 2) | ((B4 >> 6) & 0x03))
    return pixels


raw_file = sys.argv[1]
nb_regs = int(sys.argv[2])

# Each register needs 6 pixels; MIPI packs 4 pixels per 5 packed bytes,
# and each packed byte occupies 2 file bytes, so read generously.
bytes_needed = (((nb_regs * 6 + 3) // 4) * 5 + 4) * 2

exposure_hi = None
exposure_lo = None
gain_hi = None
gain_lo = None
current_exposure_hi = None
current_exposure_lo = None
ir_led = None

with open(raw_file, 'rb') as f:
    raw = f.read(bytes_needed)

pixels = decode_mipi_raw10(raw)

for i in range(nb_regs):
    base = i * 6
    reghi = pixels[base + 1]
    reglo = pixels[base + 3]
    val   = pixels[base + 5]
    reg_addr = (reghi << 8) | reglo
    print('0x{:04X} -> 0x{:02X}'.format(reg_addr, val))

    if reg_addr == 0x3501:
        exposure_hi = val
    elif reg_addr == 0x3502:
        exposure_lo = val
    elif reg_addr == 0x350E:
        current_exposure_hi = val
    elif reg_addr == 0x350F:
        current_exposure_lo = val
    elif reg_addr == 0x3508:
        gain_hi = val
    elif reg_addr == 0x3509:
        gain_lo = val
    elif reg_addr == 0x3920:
        ir_led = val

if exposure_hi is not None and exposure_lo is not None:
    exposure = (exposure_hi << 8) | exposure_lo
    print('\nExposure: 0x{:04X} ({})'.format(exposure, exposure))

if current_exposure_hi is not None and current_exposure_lo is not None:
    current_exposure = (current_exposure_hi << 8) | current_exposure_lo
    print('Current Exposure: 0x{:04X} ({})'.format(current_exposure, current_exposure))

if gain_hi is not None and gain_lo is not None:
    gain = (gain_hi << 4) | (gain_lo >> 4)
    print('Gain: 0x{:04X} ({})'.format(gain, gain))

if ir_led is not None:
    ir_status = 'ON' if ir_led == 0xFF else 'OFF'
    print('IR LED: {} (0x{:02X})'.format(ir_status, ir_led))
