#!/bin/bash

dev1=$1
dev2=$2

v4l2-ctl --stream-mmap -v width=1600,height=1300,pixelformat=BGI0 -d$dev1 --stream-count=100 --verbose & \
v4l2-ctl --stream-mmap -v width=1600,height=1300,pixelformat=BGI0 -d$dev2 --stream-count=100 --verbose
