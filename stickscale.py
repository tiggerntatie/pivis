#!/usr/bin/env python

import math
import cairo

WIDTH, HEIGHT = 2*10400, 2*300

CMW, CMH = 104.00, 3.0
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
ystart = CMH-0.02 # all marks start near the bottom
for cm in range (0,101): # for every cm along the stick
    for mm in range (0,10,2): # for every other mm in the cm
        if mm and cm == 100:
            break
        if not mm:
            marklength = 1.6 # 2 cm mark for first
        else:
            marklength = 0.8 # 8 mm mark for others
        xstart = cm + CMW/2.0 - 50.0 + mm/10.0 + markwidth/2.0
        yend = CMH-marklength
        ytext = CMH-marklength+BIGFONTSIZE
        ysmtext = CMH-marklength-0.05

        ctx.move_to (xstart,ystart)
        ctx.line_to (xstart,yend)
        ctx.set_source_rgb(0,0,0)
        ctx.set_line_width(markwidth)
        ctx.stroke()
        
        if not mm:
            text = str(cm)
            ctx.set_font_size(BIGFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(cm-x_advance + CMW/2.0 - 50.0, ytext)
        else:
            text = str(mm)
            ctx.set_font_size(SMFONTSIZE)
            (x_bearing, y_bearing, width, height, x_advance, y_advance) = ctx.text_extents(text)
            ctx.move_to(xstart-width/2.0-markwidth/2.0, ysmtext)
        ctx.text_path(text)
        ctx.fill_preserve()
        ctx.set_line_width(0.0)
        ctx.stroke()
            

surface.write_to_png ("stickscale.png") # Output to PNG
