#!/bin/bash
dev=$1
yavta -s 1920x1080 -f SRGGB8 /dev/video-imx219-cam$dev -c
