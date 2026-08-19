#!/bin/bash

set -e

# Start random_exposure.sh in background
./random_exposure.sh -r &
CMD1_PID=$!

# Ensure random_exposure.sh is killed on script exit
trap "kill $CMD1_PID 2>/dev/null || true" EXIT

# Wait 100ms
sleep 0.1

nb=$1

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-ir-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin" \
v4l2src device=/dev/video-ov2312-rgb-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"


#gst-launch-1.0 \
#v4l2src device=/dev/video3 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin" \
#v4l2src device=/dev/video4 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"

