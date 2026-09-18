#!/bin/bash

n=$1
frames=$2

yavta -s 1600x2 -f GENERIC_CSI2_10 -c$frames /dev/video$n -Fov2312-emb-frame-#.bin

#scp *.bin rishikesh@172.24.233.149:~/images/

