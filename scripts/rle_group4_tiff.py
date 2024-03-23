#!/usr/bin/env python3

# A lot of this is based on the script that ships with brother-scand.

from PIL import Image
import math
import sys

def rle_decode(data):
    """Decodes PackBits encoded data."""
    i = 0
    output = bytearray()
    while i < len(data):
        val = data[i]
        i += 1
        if val == 0x80:
            continue
        if val > 0x80:
            repeats = 0x101 - val
            output += data[i:i + 1] * repeats
            i += 1
        else:
            output += data[i:i + val + 1]
            i += val + 1
    return output

xdpi, ydpi, width = map(int, sys.argv[1:4])
filename = sys.argv[4]
destname = sys.argv[5]

rle_data = open(filename, 'rb').read()
data = rle_decode(rle_data)
height = len(data) * 8 // width
img = Image.new("1", (width, height), 1)
bytes_per_row = math.floor((width + 7) / 8)
bytes_processed = 0
x = 0
y = 0
for byte in data:
    for i in range(7, 0, -1):
        if byte & (1 << i) == (1 << i):
            img.putpixel((x, y), 0)

        x += 1

        if x == width:
            break

    bytes_processed += 1

    if bytes_processed % bytes_per_row == 0:
        x = 0
        y += 1

img.save(destname, compression="group4", dpi=(xdpi, ydpi))
