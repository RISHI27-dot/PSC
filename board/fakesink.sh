#!/bin/bash

dev=$1

gst-launch-1.0 \
v4l2src device=/dev/video-imx219-cam$dev name=v4l2_2 io-mode=5 ! queue max-size-buffers=1 leaky=2 ! video/x-bayer,width=1920,height=1080,framerate=30/1,format=rggb ! \
tiovxisp sink_0::device=/dev/v4l-imx219-subdev1 sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1920x1080.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1920x1080.bin format-msb=7 ! \
video/x-raw,format=NV12, width=1920,height=1080 ! queue ! fakesink
