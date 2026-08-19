#!/bin/bash

cam=$1
pc_ip=$2
frames=$3

if [[ -z "$cam" || -z "$pc_ip" || -z "$frames" ]]; then
  cat <<EOF
Usage:
      ./cap_frames.sh <cam> <pc_ip> <frames>
EOF

  cat <<EOF
Options:
      rc        :     camera number (/dev/video-imx219-camX)
      pc_ip     :     rishikesh@ws's IP
      frames    :     number of frames
EOF
  exit
fi

yavta -f SRGGB8 -s 1920x1080 -c$frames -Fcam$cam-frame#.bin /dev/video-imx219-cam$cam
scp cam$cam*.bin rishikesh@$pc_ip:~/images/
