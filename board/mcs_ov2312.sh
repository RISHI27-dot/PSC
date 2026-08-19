#!/bin/bash

media-ctl -R '"ds90ub960 4-0030" [0/0 -> 5/0 [1], 0/1 -> 5/1 [1]]'
media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none colorspace:srgb]'
media-ctl -V '"ds90ub960 4-0030":0/1 [fmt:SBGGI10_1X10/1600x1300 field:none colorspace:srgb]'

