#!/bin/bash

n=$1
frames=$2

yavta -s 1600x1300 -f BGGI10 -c$frames -Fov2312_60fsp-#.bin /dev/video$n

scp *.bin rishikesh@10.24.52.125:~/PSC/frames
