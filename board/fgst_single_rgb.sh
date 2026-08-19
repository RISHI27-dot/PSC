#!/bin/bash

gst-launch-1.0 \
v4l2src device=/dev/video-ov2312-rgb-cam0 io-mode=5 ! video/x-bayer, width=1600, height=1300, format=bggi10 ! queue leaky=2 ! \
tiovxisp sensor-name=SENSOR_OV2312_UB953_LI \
dcc-isp-file=/opt/imaging/ov2312/linear/dcc_viss.bin \
sink_0::dcc-2a-file=/opt/imaging/ov2312/linear/dcc_2a.bin sink_0::device=/dev/v4l-ov2312-subdev0 format-msb=9 \
sink_0::pool-size=8 src::pool-size=8 ! \
video/x-raw, format=NV12, width=1600, height=1300 ! \
queue ! fakevideosink sync=false
