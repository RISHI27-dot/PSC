#!/bin/bash

dev=$1

gst-launch-1.0 \
v4l2src device=/dev/video-ov5640-cam$dev ! video/x-raw, width=640,height=480, format=YUY2 ! ticolorconvert ! queue ! mosaic.sink_0 \
timosaic name=mosaic \
sink_0::startx=300 sink_0::starty=0 sink_0::width=640 sink_0::height=480 ! \
video/x-raw, width=1920, height=1080, format=NV12 ! queue ! kmssink driver-name=tidss sync=false force-modesetting=true
