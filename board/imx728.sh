#!/bin/bash

gst-launch-1.0 -v v4l2src device=/dev/video-imx728-cam0 io-mode=dmabuf-import ! \
  video/x-bayer, width=3856, height=2176, format=rggb12, framerate=30/1 ! \
  tiovxisp sink_0::pool-size=2 sink_0::device=/dev/v4l-imx728-subdev0 sensor-name=SENSOR_SONY_IMX728_UB971_D3 \
  dcc-isp-file=/opt/imaging/imx728/wdr/dcc_viss_wdr.bin sink_0::dcc-2a-file=/opt/imaging/imx728/wdr/dcc_2a_wdr.bin format-msb=11 wdr-enabled=true ! \
  queue ! video/x-raw, format=NV12 ! tiovxmultiscaler target=0 ! video/x-raw, format=NV12, width=1920, height=1080 ! queue ! \
  mosaic_0. tiovxmosaic name=mosaic_0 target=1 src::pool-size=2 sink_0::startx="<200>" sink_0::starty="<0>" sink_0::widths="<1520>" sink_0::heights="<850>" ! \
  video/x-raw,format=NV12, width=1920, height=1080 ! queue ! \
  tiperfoverlay ! queue ! fpsdisplaysink fps-update-interval=5000 name=rgb video-sink="kmssink driver-name=tidss force-modesetting=true sync=false" text-overlay=false sync=false
