# OV2312 POC


## Goal
Capture RGB and IR frame from one `/dev/videoX` node at 60fps and capture embedded data frames form another `/dev/videoX` node at 60fps


## Branches

Kernel: https://github.com/RISHI27-dot/linux/commits/u/psc/ed_60fps/
yavta: https://github.com/RISHI27-dot/yavta/tree/psc/ed_60fps_share

## Using the code

1. Connect `ov2312` camera to `AM62A` using `v3link` board
2. Boot
3. Setup foramts and routes to setup following configuration:

/dev/video4 : RGB + IR
/dev/video5 : META10

```
# Capture format on ticsi2rx context nodes
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 1" -v width=1600,height=1300,pixelformat=BGI0
v4l2-ctl -z platform:30102000.ticsi2rx -d "30102000.ticsi2rx context 2" -v width=1600,height=2,pixelformat=MECA

# ticsi2rx
media-ctl -R '"30102000.ticsi2rx" [0/0 -> 2/0 [1], 0/1 -> 3/0 [1]]'
media-ctl -V '"30102000.ticsi2rx":0/0 [fmt:SBGGI10_1X10/1600x1300]'
media-ctl -V '"30102000.ticsi2rx":0/1 [fmt:META_10/1600x2 field:none]'

# cdns_csi2rx
media-ctl -R '"cdns_csi2rx.30101000.csi-bridge" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/0 [fmt:SBGGI10_1X10/1600x1300]'
media-ctl -V '"cdns_csi2rx.30101000.csi-bridge":0/1 [fmt:META_10/1600x2 field:none]'

# ds90ub960
media-ctl -R '"ds90ub960 4-0030" [0/0 -> 4/0 [1], 0/1 -> 4/1 [1]]'
media-ctl -V '"ds90ub960 4-0030":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none colorspace:srgb]'
media-ctl -V '"ds90ub960 4-0030":0/1 [fmt:META_10/1600x2 field:none]'

# ds90ub953
media-ctl -R '"ds90ub953 4-0044" [0/0 -> 1/0 [1], 0/1 -> 1/1 [1]]'
media-ctl -V '"ds90ub953 4-0044":0/0 [fmt:SBGGI10_1X10/1600x1300 field:none]'
media-ctl -V '"ds90ub953 4-0044":0/1 [fmt:META_10/1600x2 field:none]'

```
4. Capture 30 frames
RGB and IR frames from `/dev/video4` & Embedded data frames from `/dev/video5`

```
yavta -s 1600x1300 -f BGGI10 -c30 -Forgb_ir_60fsp-#.bin /dev/video4 & \
yavta -s 1600x2 -f GENERIC_CSI2_10 -c30 -Fov2312-emb-frame-#.bin /dev/video5
```

5. Copy the .bin frames in the `frames` directory in this folder

```
scp *.bin <pc-name>@<pc-ip>:~/PSC/frames:
```

6. Run `batch_process_mipi_60fps.py` which will do the follwoing things

- Scans frames/ for .bin files and converts them based on filename prefix, routing outputs to `MIX/`.
- `orgb_ir_60fps-*` files are converted from raw binary to `.bmp` images using `raw2bmp.py` (1600×1040,
16bpp).
- `ov2312-emb-frame-*` files are parsed for embedded MIPI register data (9 registers) via
extract_embedded_mipi.py, saving decoded output as .txt.
- After conversion, runs classify_frames.py to classify all processed frames on the basis of the Current Exposure 

```
python3 batch_process_mipi_60fps.py
```

## Conclusion
If the CSI HW does the filtering correctly, the `MIX/rgb` should have RGB frames and `MIX/ir` should have ir frames

## Problems
- Due to some reason `MIX/rgb` and `MIX/ir` have mixed frames.

The most possible reaosn I could thing that `orgb_ir_60fps-#` frame is being mapped to wrong `ov2312-emb-frame-#` because yavta commands in step 4 are not capturing the frames in sync.