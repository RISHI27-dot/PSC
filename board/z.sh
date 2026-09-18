#!/bin/bash

media-ctl -R '"ds90ub960 4-0030" [0/0 -> 5/0 [1]]'
media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SRGGB8_1X8/1920x1080 field: none]'
