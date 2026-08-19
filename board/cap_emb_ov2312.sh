#!/bin/bash

n=$1

yavta -s 1600x2 -f GENERIC_8 -c5 /dev/video$n -Fov2312-emb-frame-#.bin

#scp *.bin rishikesh@172.24.233.149:~/images/

