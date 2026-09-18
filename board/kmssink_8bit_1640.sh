#!/bin/bash

gst-launch-1.0 v4l2src io-mode=dmabuf-import device=/dev/video-imx219-cam0 ! video/x-bayer,width=1640,height=1232,format=rggb, framerate=30/1 ! \
tiovxisp sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1640x1232.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1640x1232.bin sink_0::device=/dev/v4l-imx219-subdev0 format-msb=9 ! \
video/x-raw,format=NV12 ! queue ! kmssink driver-name=tidss plane-properties=s,zpos=1
