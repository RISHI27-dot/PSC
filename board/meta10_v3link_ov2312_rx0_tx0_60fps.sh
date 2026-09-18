#!/bin/bash

# Capture format on ticsi2rx context nodes
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 1" -v width=1600,height=1300,pixelformat=BGI0
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 2" -v width=1600,height=2,pixelformat=MECA

# ticsi2rx: route 3 streams to 3 output pads
media-ctl -R '"30102000.ticsi2rx" [0/0 -> 2/0 [1], 0/1 -> 3/0 [1]]'
media-ctl -V '"30102000.ticsi2rx":0/0 [fmt:SBGGI10_1X10/1600x1300]'
media-ctl -V '"30102000.ticsi2rx":0/1 [fmt:META_10/1600x2 field:none]'

# cdns_csi2rx: all 3 streams pass through pad0 -> pad1
media-ctl -R '"cdns_csi2rx.30101000.csi-bridge" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/0 [fmt:SBGGI10_1X10/1600x1300]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/1 [fmt:META_10/1600x2 field:none]'

# ds90ub960: input on pad0 (ov2312), output on pad5 (CSI2 TX)
media-ctl -R '"ds90ub960 4-0030" [0/0 -> 4/0 [1], 0/1 -> 4/1 [1]]'
media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none colorspace:srgb]'
media-ctl -V '"ds90ub960 4-0030":0/1 [fmt:META_10/1600x2 field:none]'

# ds90ub953
media-ctl -R '"ds90ub953 4-0044" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"ds90ub953 4-0044":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none]'
media-ctl -V '"ds90ub953 4-0044":0/1 [fmt:META_10/1600x2 field:none]'

# ov2312: routes are immutable, only format needed
#media-ctl -V '"ov2312 6-0060":0/0 [fmt:SBGGI10_1X10/1600x1300]'
#media-ctl -V '"ov2312 6-0060":0/1 [fmt:SBGGI10_1X10/1600x1300]'
#media-ctl -V '"ov2312 6-0060":0/2 [fmt:META_10/1600x2]'

