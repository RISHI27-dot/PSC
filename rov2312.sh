#!/bin/bash

nb=$1

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-ir-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="ir_%03d.bin"

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-rgb-cam0 num-buffers=$nb ! video/x-bayer, width=1600, height=1300, format=bggi10 ! multifilesink location="rgb_%03d.bin"

scp rgb*.bin rishikesh@172.24.233.149:/home/rishikesh/PSC/RGB-VC1/
scp ir*.bin rishikesh@172.24.233.149:/home/rishikesh/PSC/IR-VC0/

#tar -czvf rgb.tar.gz rgb*.bin
#tar --zstd -cvf ir.tar.zst ir*.bin
#scp rgb.tar.gz rishikesh@172.24.233.149:/home/rishikesh/PSC/RGB-VC1/
#scp ir.tar.zst rishikesh@172.24.233.149:/home/rishikesh/PSC/IR-VC0/

rm *.bin
