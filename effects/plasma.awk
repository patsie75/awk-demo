function init_plasma() {
  paletteGen()
}

## generate palette
function paletteGen(    x, r,g,b) {
  for (x=0; x<256; x++) {
    r = 128 + 127 * sin(3.14159265 * x / 32.0)
    g = 128 + 127 * sin(3.14159265 * x / 64.0)
    b = 128 + 127 * sin(3.14159265 * x / 128.0)
    palette[x] = sprintf("%d;%d;%d", clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
  }
}

function plasma001(plasma, w, h,    x,y, color) {
  for (y=0; y<h; y++) {
    for (x=0; x<w; x++) {
      color = ( \
         128.0 + (128.0 * sin((x / 8.0) - cos(elapsed/2) )) \
       + 128.0 + (128.0 * sin((y / 8.0) - sin(elapsed)*2 )) \
      ) / 2

      plasma[x,y] = int(color)
    }
  }
}

function plasma002(plasma, w, h,    x,y, color) {
  for (y=0; y<h; y++) {
    for (x=0; x<w; x++) {
      color = ( \
          128.0 + (128.0 * sin((x / 8.0) - cos(elapsed/2) )) \
        + 128.0 + (128.0 * sin((y / 4.0) - sin(elapsed)*2 )) \
        + 128.0 + (128.0 * sin((x + y) / 8.0)) \
        + 128.0 + (128.0 * sin((sqrt(x * x + y * y) / 4.0) - sin(elapsed)*4)) \
      ) / 4;

      plasma[x,y] = int(color)
    }
  }
}

function plasma003(plasma, w, h,    x,y, color) {
  for (y=0; y<h; y++) {
    for (x=0; x<w; x++) {
      color = ( \
          128.0 + (128.0 * sin((x / 8.0) - cos(elapsed/2) )) \
        + 128.0 + (128.0 * sin((y / 16.0) - sin(elapsed)*2 )) \
        + 128.0 + (128.0 * sin(sqrt((x - w / 2.0) * (x - w / 2.0) + (y - h / 2.0) * (y - h / 2.0)) / 4.0)) \
        + 128.0 + (128.0 * sin((sqrt(x * x + y * y) / 4.0) - sin(elapsed/4) )) \
      ) / 4;

      plasma[x,y] = int(color)
    }
  }
}

function do_plasma(buf) {
  w = buf["width"]
  h = buf["height"]

  if (( 76 <= elapsed) && (elapsed <  92)) plasma001(plasma, w, h)
  if (( 92 <= elapsed) && (elapsed < 108)) plasma002(plasma, w, h)
  if ((108 <= elapsed) && (elapsed < 124)) plasma003(plasma, w, h)

  # loop colors based on time
  paletteShift = elapsed * 100

  # copy plasma to buffer 
  for (y=0; y<h; y++)
    for (x=0; x<w; x++)
      buf[x,y] = palette[int(plasma[x,y] + paletteShift) % 256]

}
