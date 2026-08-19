#!/bin/bash

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-rgb-cam0 io-mode=2 num-buffers=100 ! \
video/x-bayer, width=1600, height=1300, format=bggi10 ! \
identity sleep-time=100000 silent=false ! \
fakesink -v
