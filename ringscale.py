#!/usr/bin/env python

import math
import cairo

WIDTH, HEIGHT = 31416, 300

CMW, CMH = 314.1592654, 3.0
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

markwidth = 0.1 # 1 mm wide ticks
ystart = CMH/2.0 # all marks start at the midline
for cm in range (0,316): # for every cm around the ring
    for mm in range (0,10,2): # for every other mm in the cm
        if not mm:
            marklength = 1.0 # 1 cm mark for first
        else:
            marklength = 0.4 # 4 mm mark for others
        xstart = cm + mm/10.0 + markwidth/2.0
        if ((cm == 314) and mm):
            xstart -= CMW
        if cm < 155:
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
            text = str(cm)
            ctx.set_font_size(BIGFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(cm-x_advance, ytext)
        else:
            text = str(mm)
            ctx.set_font_size(SMFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(xstart-width/2.0-markwidth/2.0, ysmtext)
        ctx.text_path(text)
        ctx.fill_preserve()
        ctx.set_line_width(0.0)
        ctx.stroke()
            

surface.write_to_png ("ringscale.png") # Output to PNG
