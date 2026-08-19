#!/bin/bash

media-ctl -R '"ds90ub960 4-0030" [0/0 -> 4/0 [1], 1/0 -> 4/1 [1]]'
media-ctl -R '"cdns_csi2rx.30101000.csi-bridge" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -R '"30102000.ticsi2rx" [0/0 -> 2/0 [1], 0/1 -> 3/0 [1]]'

media-ctl -V '"imx219 6-0010":0[fmt:SRGGB8_1X8/1920x1080]'
media-ctl -V '"imx219 7-0010":0[fmt:SRGGB8_1X8/1920x1080]'

media-ctl -V '"ds90ub953 4-0044":0[fmt:SRGGB8_1X8/1920x1080 field: none]'
media-ctl -V '"ds90ub953 4-0045":0[fmt:SRGGB8_1X8/1920x1080 field: none]'

media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SRGGB8_1X8/1920x1080 field: none]'
media-ctl -V '"ds90ub960 4-0030":1/0 [fmt:SRGGB8_1X8/1920x1080 field: none]'

media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/0 [fmt:SRGGB8_1X8/1920x1080]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/1 [fmt:SRGGB8_1X8/1920x1080]'

media-ctl -V '"30102000.ticsi2rx":0/0 [fmt:SRGGB8_1X8/1920x1080]'
media-ctl -V '"30102000.ticsi2rx":0/1 [fmt:SRGGB8_1X8/1920x1080]'
