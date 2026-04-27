#!/bin/bash

# Script to repeatedly set exposure on OV2312 device with random values and delays

DEVICE="/dev/v4l-ov2312-subdev0"
MIN_EXPOSURE=200
MAX_EXPOSURE=2500
MIN_DELAY=0.016
MAX_DELAY=0.032
ITERATIONS=0

# Print usage
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -d DEVICE         Device path (default: $DEVICE)"
    echo "  -m MIN            Minimum exposure value (default: $MIN_EXPOSURE)"
    echo "  -M MAX            Maximum exposure value (default: $MAX_EXPOSURE)"
    echo "  -l MIN_DELAY      Minimum delay between commands in seconds (default: $MIN_DELAY)"
    echo "  -L MAX_DELAY      Maximum delay between commands in seconds (default: $MAX_DELAY)"
    echo "  -n ITERATIONS     Number of iterations (0 = infinite, default: $ITERATIONS)"
    echo "  -h                Show this help message"
    exit 1
}

# Parse command line arguments
while getopts "d:m:M:l:L:n:h" opt; do
    case $opt in
        d) DEVICE="$OPTARG" ;;
        m) MIN_EXPOSURE="$OPTARG" ;;
        M) MAX_EXPOSURE="$OPTARG" ;;
        l) MIN_DELAY="$OPTARG" ;;
        L) MAX_DELAY="$OPTARG" ;;
        n) ITERATIONS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate device exists
if [ ! -e "$DEVICE" ]; then
    echo "Error: Device $DEVICE not found"
    exit 1
fi

# Check if v4l2-ctl is available
if ! command -v v4l2-ctl &> /dev/null; then
    echo "Error: v4l2-ctl not found. Please install v4l-utils"
    exit 1
fi

# Display configuration
echo "OV2312 Exposure Control Script"
echo "=============================="
echo "Device: $DEVICE"
echo "Exposure range: $MIN_EXPOSURE - $MAX_EXPOSURE"
echo "Delay range: $MIN_DELAY - $MAX_DELAY seconds"
if [ $ITERATIONS -eq 0 ]; then
    echo "Mode: Infinite (press Ctrl+C to stop)"
else
    echo "Iterations: $ITERATIONS"
fi
echo "=============================="
echo ""

# Counter for iterations
count=0

# Main loop
while true; do
    # Generate random exposure value
    EXPOSURE=$((MIN_EXPOSURE + RANDOM % (MAX_EXPOSURE - MIN_EXPOSURE + 1)))

    # Generate random delay (supporting floating point)
    DELAY=$(awk -v min="$MIN_DELAY" -v max="$MAX_DELAY" 'BEGIN {srand(); print min + rand() * (max - min)}')

    # Set exposure
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Setting exposure to $EXPOSURE"
    v4l2-ctl -d "$DEVICE" --set-ctrl exposure=$EXPOSURE

    if [ $? -eq 0 ]; then
        echo "  ✓ Exposure set successfully"
    else
        echo "  ✗ Failed to set exposure"
    fi

    # Increment counter
    ((count++))

    # Check if we've reached the iteration limit
    if [ $ITERATIONS -gt 0 ] && [ $count -ge $ITERATIONS ]; then
        echo ""
        echo "Completed $count iterations. Exiting."
        break
    fi

    # Wait for random delay
    echo "  Waiting ${DELAY}s before next command..."
    sleep "$DELAY"
    echo ""
done
