function init_fire(buf) {
  flameheight    = 3.7	; # between 2.0 and 5.0
  flameintensity = 0.9	; # between 0.5 and 1.0
  flamedecay     = 16/67; # this is pretty much the ideal
  frame          = 0

  w = buf["width"]
  h = buf["height"]

  # generate colors (black to red to yellow to white)
  colors = 0
  for (i=0; i<256; i+=1)
    color[colors++] = sprintf("%d;0;0", i)
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("255;%d;%d", i, i/4)
  for (i=79; i<256; i+=16)
    color[colors++] = sprintf("255;255;%d", i)

  # generate colors (black to green to yellow to white)
  for (i=0; i<256; i+=1)
    color[colors++] = sprintf("0;%d;0", i)
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("%d;255;%d", i, i/4)
  for (i=79; i<256; i+=16)
    color[colors++] = sprintf("255;255;%d", i)

  # generate colors (black to dark blue to light blue to white)
  for (i=0; i<256; i+=1)
    color[colors++] = sprintf("0;0;%d", i)
  for (i=0; i<256; i+=4)
    color[colors++] = sprintf("%d;%d;255", i/4, i)
  for (i=79; i<256; i+=16)
    color[colors++] = sprintf("%d;255;255", i)

  colors /= 3
}

function do_fire(buf) {
  frame++

  # randomize bottom row
  for (x=clamp( (w/2)-(frame/2), 0, w/2); x<clamp( (w/2)+(frame/2), w/2, w); x++)
    scr[x,h+4] = rand() * (colors*flameintensity) + (colors*(1-flameintensity)) / 10

  # process all rows
  for (y=0; y<h+4; y+=2) {
    # set cursor position
    line = sprintf("\033[%0d;%0dH", y/2+1, 1)

    for (x=0; x<w; x++) {
      # calculate new value for pixel, store and add to line
      scr[x,y+0] = (scr[x-1,y+1] + scr[x,y+1] + scr[x+1,y+1] + scr[x,y+2]) * flamedecay
      scr[x,y+1] = (scr[x-1,y+2] + scr[x,y+2] + scr[x+1,y+2] + scr[x,y+3]) * flamedecay

      up = clamp(int(scr[x,y+0] * flameheight), 0, colors-1)
      dn = clamp(int(scr[x,y+1] * flameheight), 0, colors-1)

      up += int(x / (int(w/3)+1) ) * 332
      dn += int(x / (int(w/3)+1) ) * 332

      if (y<h) {
        buf[x,y+0] = color[up]
        buf[x,y+1] = color[dn]
      }
    }
  }
}
