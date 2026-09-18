#!/bin/bash

# Script to repeatedly set multi-capture exposure on OV2312 using V4L2_CID_EXPOSURE_MULTI
# Index [0] = RGB (Group B, long exposure), Index [1] = IR (Group A, short exposure)
# Uses ov2312-ctrl: ./ov2312-ctrl -e <rgb>,<ir>

TOOL="./ov2312-ctrl"

# RGB exposure range
MIN_RGB=1200
MAX_RGB=1400

# IR exposure range
MIN_IR=100
MAX_IR=160

MIN_DELAY=0.016
MAX_DELAY=0.032
ITERATIONS=0
RANDOM_MODE=false
FIXED_RGB=""
FIXED_IR=""

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -t TOOL           Path to ov2312-ctrl binary (default: $TOOL)"
    echo "  -e RGB,IR         Fixed RGB and IR exposure values"
    echo "  -r                Use random exposure values"
    echo "  -m MIN_RGB        Min RGB exposure for random mode (default: $MIN_RGB)"
    echo "  -M MAX_RGB        Max RGB exposure for random mode (default: $MAX_RGB)"
    echo "  -i MIN_IR         Min IR exposure for random mode (default: $MIN_IR)"
    echo "  -I MAX_IR         Max IR exposure for random mode (default: $MAX_IR)"
    echo "  -l MIN_DELAY      Minimum delay between commands in seconds (default: $MIN_DELAY)"
    echo "  -L MAX_DELAY      Maximum delay between commands in seconds (default: $MAX_DELAY)"
    echo "  -n ITERATIONS     Number of iterations (0 = infinite, default: $ITERATIONS)"
    echo "  -h                Show this help message"
    exit 1
}

while getopts "t:e:rm:M:i:I:l:L:n:h" opt; do
    case $opt in
        t) TOOL="$OPTARG" ;;
        e)
            FIXED_RGB="${OPTARG%%,*}"
            FIXED_IR="${OPTARG##*,}"
            ;;
        r) RANDOM_MODE=true ;;
        m) MIN_RGB="$OPTARG" ;;
        M) MAX_RGB="$OPTARG" ;;
        i) MIN_IR="$OPTARG" ;;
        I) MAX_IR="$OPTARG" ;;
        l) MIN_DELAY="$OPTARG" ;;
        L) MAX_DELAY="$OPTARG" ;;
        n) ITERATIONS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

if [ "$RANDOM_MODE" = false ] && { [ -z "$FIXED_RGB" ] || [ -z "$FIXED_IR" ]; }; then
    echo "Error: Either -r (random mode) or -e RGB,IR (fixed values) must be specified"
    usage
fi

if ! command -v "$TOOL" &> /dev/null && [ ! -x "$TOOL" ]; then
    echo "Error: $TOOL not found. Build tools/media/ov2312-ctrl.c first."
    exit 1
fi

echo "OV2312 Multi-Capture Exposure Control Script"
echo "============================================"
echo "Tool: $TOOL"
if [ "$RANDOM_MODE" = true ]; then
    echo "RGB exposure: random ($MIN_RGB - $MAX_RGB)"
    echo "IR  exposure: random ($MIN_IR - $MAX_IR)"
else
    echo "RGB exposure: fixed ($FIXED_RGB)"
    echo "IR  exposure: fixed ($FIXED_IR)"
fi
echo "Delay range: $MIN_DELAY - $MAX_DELAY seconds"
if [ "$ITERATIONS" -eq 0 ]; then
    echo "Mode: Infinite (press Ctrl+C to stop)"
else
    echo "Iterations: $ITERATIONS"
fi
echo "============================================"
echo ""

count=0

while true; do
    if [ "$RANDOM_MODE" = true ]; then
        RGB_EXP=$((MIN_RGB + RANDOM % (MAX_RGB - MIN_RGB + 1)))
        IR_EXP=$((MIN_IR + RANDOM % (MAX_IR - MIN_IR + 1)))
    else
        RGB_EXP="$FIXED_RGB"
        IR_EXP="$FIXED_IR"
    fi

    DELAY=$(awk -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN {srand(); print min + rand() * (max - min)}')

    echo "[$(date '+%H:%M:%S.%3N')] Setting exposure: RGB=$RGB_EXP IR=$IR_EXP"
    "$TOOL" -e "$RGB_EXP,$IR_EXP"

    ((count++))

    if [ "$ITERATIONS" -gt 0 ] && [ "$count" -ge "$ITERATIONS" ]; then
        echo ""
        echo "Completed $count iterations. Exiting."
        break
    fi

    sleep "$DELAY"
done
