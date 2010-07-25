#!/usr/bin/env python

# ringscale EXCERPT
# construct full size texture:
#
# convert ringscalex.png -background transparent -extent 62832x600 -gravity West ringscalexx.png

# one tick per mm

import math
import cairo

WIDTH, HEIGHT = 3142*2, 300*2

CMW, CMH = 31.41592654, 3.0
SW, SH = WIDTH/CMW, HEIGHT/CMH

BIGFONTSIZE = 0.35
SMFONTSIZE = 0.15

surface = cairo.ImageSurface (cairo.FORMAT_ARGB32, WIDTH, HEIGHT)
ctx = cairo.Context (surface)

ctx.scale (SW, SH) # Normalizing the canvas


ctx.rectangle (0, 0, CMW, CMH) # Rectangle(x0, y0, x1, y1)
ctx.set_source_rgba (0,0,0,0)
ctx.fill ()

ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)

markwidth = 0.025 # 0.25 mm wide ticks
ystart = CMH/2.0 # all marks start at the midline
for cm in range (0,32): # for every cm around the ring
    cmx = cm-16
    if cmx < 0:
        cmx = cmx+315
    cml = cm
    if cml < 16:
        cml = cml+1.0-0.1592654
    for mm in range (0,10,1): # for every mm in the cm
        if not mm:
            marklength = 1.0 # 1 cm mark for first
        else:
            marklength = 0.4 # 4 mm mark for others
        xstart = cml + mm/10.0
#        if ((cmx == 314) and mm):
#            xstart -= CMW
        if cmx < 155:
            yend = CMH/2.0-marklength
            ytext = CMH/2.0-marklength+BIGFONTSIZE
            ysmtext = CMH/2.0-marklength-0.05
        else:
            yend = CMH/2.0+marklength
            ytext = CMH/2.0+marklength
            ysmtext = CMH/2.0+marklength+SMFONTSIZE+0.05
        ctx.move_to (xstart,ystart)
        ctx.line_to (xstart,yend)
        ctx.set_source_rgb(0,0,0)
        ctx.set_line_width(markwidth)
        ctx.stroke()
        
        if not mm:
            text = str(cmx)
            ctx.set_font_size(BIGFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(cml-x_advance - markwidth, ytext)
        elif not mm % 2:
            text = str(mm)
            ctx.set_font_size(SMFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(xstart-width/2.0, ysmtext)
        ctx.text_path(text)
        ctx.fill_preserve()
        ctx.set_line_width(0.0)
        ctx.stroke()
            

surface.write_to_png ("ringscale-ax.png") # Output to PNG
