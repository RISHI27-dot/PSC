#!/bin/bash

gst-launch-1.0 \
v4l2src device=/dev/video-imx219-cam0 io-mode=5 ! queue max-size-buffers=1 leaky=2 ! video/x-bayer,width=1920,height=1080,framerate=30/1,format=rggb ! \
tiovxisp sink_0::device=/dev/v4l-imx219-subdev0 sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1920x1080.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1920x1080.bin format-msb=7 ! \
video/x-raw,format=NV12, width=1920,height=1080 ! queue ! mosaic.sink_0 \
v4l2src device=/dev/video-imx219-cam1 io-mode=5 ! queue max-size-buffers=1 leaky=2 ! video/x-bayer,width=1920,height=1080,framerate=30/1,format=rggb ! \
tiovxisp sink_0::device=/dev/v4l-imx219-subdev1 sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1920x1080.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1920x1080.bin format-msb=7 ! \
video/x-raw,format=NV12, width=1920,height=1080 ! queue ! mosaic.sink_1 \
v4l2src device=/dev/video-imx219-cam2 io-mode=5 ! queue max-size-buffers=1 leaky=2 ! video/x-bayer,width=1920,height=1080,framerate=30/1,format=rggb ! \
tiovxisp sink_0::device=/dev/v4l-imx219-subdev2 sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1920x1080.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1920x1080.bin format-msb=7 ! \
video/x-raw,format=NV12, width=1920,height=1080 ! queue ! mosaic.sink_2 \
v4l2src device=/dev/video-imx219-cam3 io-mode=5 ! queue max-size-buffers=1 leaky=2 ! video/x-bayer,width=1920,height=1080,framerate=30/1,format=rggb ! \
tiovxisp sink_0::device=/dev/v4l-imx219-subdev3 sensor-name=SENSOR_SONY_IMX219_RPI dcc-isp-file=/opt/imaging/imx219/linear/dcc_viss_1920x1080.bin \
sink_0::dcc-2a-file=/opt/imaging/imx219/linear/dcc_2a_1920x1080.bin format-msb=7 ! \
video/x-raw,format=NV12, width=1920,height=1080 ! queue ! mosaic.sink_3 \
tiovxmosaic name=mosaic \
sink_0::startx="<0>" sink_0::starty="<0>" sink_0::widths="<640>" sink_0::heights="<480>" \
sink_1::startx="<0>" sink_1::starty="<480>" sink_1::widths="<640>" sink_1::heights="<480>" \
sink_2::startx="<640>" sink_2::starty="<0>" sink_2::widths="<640>" sink_2::heights="<480>" \
sink_3::startx="<640>" sink_3::starty="<480>" sink_3::widths="<640>" sink_3::heights="<480>" ! \
queue ! video/x-raw, width=1920, height=1080 ! queue ! kmssink driver-name=tidss sync=false force-modesetting=true
