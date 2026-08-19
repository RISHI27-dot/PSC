#!/bin/bash

nb=$1

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-ir-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin" & \
v4l2-ctl -d /dev/v4l-ov2312-subdev0 --set-ctrl exposure=100 && sleep 0.05 && \ 
v4l2-ctl -d /dev/v4l-ov2312-subdev0 --set-ctrl exposure=100 && sleep 0.05 && \ 
v4l2-ctl -d /dev/v4l-ov2312-subdev0 --set-ctrl exposure=100 && sleep 0.05

#gst-launch-1.0 \
#v4l2src device=/dev/video-ov2312-rgb-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"

#scp rgb*.bin rishikesh@172.24.233.149:/home/rishikesh/PSC/RGB-VC1/
scp ir*.bin rishikesh@172.24.233.149:/home/rishikesh/PSC/IR-VC0/

