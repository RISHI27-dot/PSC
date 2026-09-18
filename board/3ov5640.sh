#!/bin/bash

gst-launch-1.0 \
  v4l2src device=/dev/video-ov5640-cam0 ! video/x-raw, width=640,height=480, format=YUY2 ! ticolorconvert ! queue ! mosaic.sink_0 \
  v4l2src device=/dev/video-ov5640-cam1 ! video/x-raw, width=640,height=480, format=YUY2 ! ticolorconvert ! queue ! mosaic.sink_1 \
  v4l2src device=/dev/video-ov5640-cam2 ! video/x-raw, width=640,height=480, format=YUY2 ! ticolorconvert ! queue ! mosaic.sink_2 \
  timosaic name=mosaic \
  sink_0::startx=300 sink_0::starty=0 sink_0::width=640 sink_0::height=480 \
  sink_1::startx=980 sink_1::starty=0 sink_1::width=640 sink_1::height=480 \
  sink_2::startx=300 sink_2::starty=500 sink_2::width=640 sink_2::height=480 ! \
  video/x-raw, width=1920, height=1080, format=NV12 ! queue ! kmssink driver-name=tidss sync=false force-modesetting=true
