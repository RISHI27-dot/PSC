#!/bin/bash

nb=$1

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-ir-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin" \
v4l2src device=/dev/video-ov2312-rgb-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"

