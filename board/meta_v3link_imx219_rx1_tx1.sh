v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 0" -v width=1920,height=1080,pixelformat=RGGB
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 1" -v width=1920,height=2,pixelformat=MET8


media-ctl -R '"30102000.ticsi2rx" [0/0 -> 1/0 [1], 0/1 -> 2/0 [1]]'
media-ctl -V '"30102000.ticsi2rx":0/0 [fmt:SRGGB8_1X8/1920x1080]'
media-ctl -V '"30102000.ticsi2rx":0/1 [fmt:META_8/1920x2 field:none]'


media-ctl -R '"cdns_csi2rx.30101000.csi-bridge" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/0 [fmt:SRGGB8_1X8/1920x1080]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/1 [fmt:META_8/1920x2 field:none]'


media-ctl -R '"ds90ub960 4-0030" [1/0 -> 5/0 [1], 1/1 -> 5/1 [1]]'
media-ctl -V '"ds90ub960 4-0030":1/0 [fmt:SRGGB8_1X8/1920x1080 field: none]'
media-ctl -V '"ds90ub960 4-0030":1/1 [fmt:META_8/1920x2 field:none]'


media-ctl -R '"ds90ub953 4-0045" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"ds90ub953 4-0045":0/0 [fmt:SRGGB8_1X8/1920x1080 field: none]'
media-ctl -V '"ds90ub953 4-0045":0/1 [fmt:META_8/1920x2 field:none]'

media-ctl -V '"imx219 6-0010":0/0[fmt:SRGGB8_1X8/1920x1080]'
