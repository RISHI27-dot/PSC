#!/bin/bash

set -e

# Start random_exposure_multi.sh in background
./random_exposure_multi.sh -r &
CMD1_PID=$!

# Ensure random_exposure.sh is killed on script exit
trap "kill $CMD1_PID 2>/dev/null || true" EXIT

nb=$1

yavta -s 1600x1300 -f BGGI10 -c$nb -Fir_#.bin /dev/video-ov2312-ir-cam0 &
yavta -s 1600x1300 -f BGGI10 -c$nb -Frgb_#.bin /dev/video-ov2312-rgb-cam0

#gst-launch-1.0 \
#v4l2src device=/dev/video-ov2312-ir-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin" \
#v4l2src device=/dev/video-ov2312-rgb-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"
