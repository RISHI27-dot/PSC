#!/usr/bin/env python
import cv2
import sys
import numpy as np



if len(sys.argv) < 5:
	print( "***** Usage syntax Error!!!! *****\n")
	print ("Usage:")
	print ("python raw2bmp.py raw_file width height bpp")
	sys.exit(1)
else:
	pass

image_name = sys.argv[1]
print( "image_name: = " , image_name)
width = int(sys.argv[2])
height = int(sys.argv[3])
bpp = sys.argv[4]
#bayer_format = cv2.COLOR_BAYER_GB2RGB

bayer_format = cv2.COLOR_BAYER_RGGB2GRAY
temp = image_name.split('.')
#print('temp = ', temp)
output_file = temp[0] + "." + "bmp"
print( "output_file: = " , output_file)


with open(image_name, "rb") as rawimg:
   img = np.fromfile(rawimg, np.dtype(np.uint16), width * height).reshape(height, width)
   img.tofile("test2.raw")
   colimg = cv2.cvtColor(img, bayer_format)
   cv2.imwrite(output_file, colimg)
   #cv2.imshow("color", colimg)
   #cv2.waitKey(0)
