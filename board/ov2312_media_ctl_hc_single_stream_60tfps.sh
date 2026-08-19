#!/bin/bash

# Set ds90ub953 routes (unchanged)
media-ctl -R '"ds90ub953 4-0044" [0/0 -> 1/0 [1]]'
media-ctl -V '"ds90ub953 4-0044":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none]'

# Set ds90ub960 routes (unchanged)
media-ctl -R '"ds90ub960 4-0030" [0/0 -> 4/0 [1]]'
media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none colorspace:srgb]'

# Set CDNS CSI Bridge (drop colorspace:srgb)
media-ctl -R '"cdns_csi2rx.30101000.csi-bridge" [0/0 -> 1/0 [1]]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none]'

# Set ticsi2rx: stream0→pad2 (video4), stream1→pad3 (video5); drop colorspace:srgb
media-ctl -R '"30102000.ticsi2rx" [0/0 -> 2/0 [1]]'
media-ctl -V '"30102000.ticsi2rx":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none]'

# Set video node formats (context 1=image, context 2=embedded data)
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 1" -v width=1600,height=1300,pixelformat=BGI0
