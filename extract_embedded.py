#!/usr/bin/env python3

import struct, sys

raw_file = sys.argv[1]
nb_regs = int(sys.argv[2])

exposure_hi = None
exposure_lo = None
gain_hi = None
gain_lo = None
current_exposure_hi = None
current_exposure_lo = None

with open(raw_file, 'rb') as raw:
    for _ in range(nb_regs):
        raw.read(2) # Padding 0s
        reghi = struct.unpack('<H', raw.read(2))[0]
        reghi >>= 2
        raw.read(2)
        reglo = struct.unpack('<H', raw.read(2))[0]
        reglo >>= 2
        raw.read(2)
        val = struct.unpack('<H', raw.read(2))[0]
        val >>= 2
        reg_addr = (reghi << 8) | reglo
        print('0x{:04X} -> 0x{:02X}'.format(reg_addr, val))

        # Track exposure registers
        if reg_addr == 0x3501:
            exposure_hi = val
        elif reg_addr == 0x3502:
            exposure_lo = val
        # Track current exposure registers
        elif reg_addr == 0x350E:
            current_exposure_hi = val
        elif reg_addr == 0x350F:
            current_exposure_lo = val
        # Track gain registers
        elif reg_addr == 0x3508:
            gain_hi = val
        elif reg_addr == 0x3509:
            gain_lo = val

# Print combined exposure and gain values
if exposure_hi is not None and exposure_lo is not None:
    exposure = (exposure_hi << 8) | exposure_lo
    print('\nExposure: 0x{:04X} ({})'.format(exposure, exposure))

if current_exposure_hi is not None and current_exposure_lo is not None:
    current_exposure = (current_exposure_hi << 8) | current_exposure_lo
    print('Current Exposure: 0x{:04X} ({})'.format(current_exposure, current_exposure))

if gain_hi is not None and gain_lo is not None:
    gain = (gain_hi << 4) | (gain_lo >> 4)
    print('Gain: 0x{:04X} ({})'.format(gain, gain))
