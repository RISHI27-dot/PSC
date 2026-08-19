#!/bin/bash

n=$1

yavta -s 1920x2 -f GENERIC_8 -c5 /dev/video$n -Femb-frame-#.bin

#scp *.bin rishikesh@172.24.233.149:~/images/

