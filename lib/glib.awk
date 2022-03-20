BEGIN {
  split(" ,▁,▂,▃,▄,▅,▆,▇,█", hblock, ",")

  glib["pi"] = atan2(0, -1)
  for (i=0; i<360; i++) {
    glib["sin",i] = sin((glib["pi"]*i)/180) * 255
    glib["SIN",i] = sin((glib["pi"]*i)/180) * 127 + 128
  }
}

function clamp(val, a, b) { return (val<a) ? a : (val>b) ? b : val }

## get timestamp with one-hundreth of a second precision
function timex() {
  getline <"/proc/uptime"
  close("/proc/uptime")
  return $1
}

function clear(dst) { fill(dst, "0;0;0") }

function blend(a, b, alpha1, alpha2,    fg, bg, r, y,z) {
  split(a, fg, ";")
  split(b, bg, ";")

  fg["A"] = alpha1/255
  bg["A"] = alpha2/255

  r["A"] = 1 - (1 - fg["A"]) * (1 - bg["A"])
  if (r["A"] < 1.0e-6) return b
  y = fg["A"] / r["A"] / 255
  z = bg["A"] * (1 - fg["A"]) / r["A"] / 255

  r["R"] = fg[1] * y + bg[1] * z
  r["G"] = fg[2] * y + bg[2] * z
  r["B"] = fg[3] * y + bg[3] * z

  return sprintf("%d;%d;%d", clamp(r["R"]*255, 0,255), clamp(r["G"]*255, 0,255), clamp(r["B"]*255, 0,255) )
}

# font.charset = character list of src-font
function write(dst, src, msg, dstx,dsty,    i, l, chr, idx, fw,fh) {
  l = length(msg)
  fw = int(src["width"] /  length(src["font","charset"]))
  fh = src["height"]

  for (i=0; i<l; i++) {
    chr = substr(msg, i+1, 1)
    if ( (idx = index(src["font","charset"], chr)-1) >= 0)
      copy(dst, src, dstx+(i*fw),dsty, (idx*fw),0, fw,fh)
  }
}


# reset graphic buffer to single color (default black)
function fill(dst, col,   x,y) {
  col = col ? col : "0;0;0"

  for (y=0; y<dst["height"]; y++)
    for (x=0; x<dst["width"]; x++)
      dst[x,y] = col
}

# copy graphic buffer to another graphic buffer (with transparency, and edge clipping)
# usage: dst, src, [dstx, dsty, [srcx, srcy, [srcw, srch, [transparent] ] ] ]
function copy(dst, src, dstx, dsty, srcx, srcy, srcw, srch, transp,   dx,dy, dw,dh, sx,sy, sw,sh, x,y, w,h, sa,da, t, pix, xdx,ydy) {
  dw = dst["width"]
  dh = dst["height"]
  sw = src["width"]
  sh = src["height"]

  if ("alpha" in src) sa = src["alpha"]; else sa = 255
  if ("alpha" in dst) da = dst["alpha"]; else da = 255

  dx = int(src["x"])
  dy = int(src["y"])
  sx = 0
  sy = 0
  w = src["width"]
  h = src["height"]

  if (dstx == dstx+0) dx = dstx
  if (dsty == dsty+0) dy = dsty
  if (srcx == srcx+0) sx = srcx
  if (srcy == srcy+0) sy = srcy
  if (srcw == srcw+0) w = ((srcw > 0) && (srcw < src["width"])) ? srcw : w
  if (srch == srch+0) h = ((srch > 0) && (srch < src["height"])) ? srch : h

  if (sprintf("%s", transp)) t = transp
  else if ("transparent" in src) t = src["transparent"]
  else if ("transparent" in glib) t = glib["transparent"]

  for (y=sy; y<(sy+h); y++) {
    # clip image off top/bottom
    if ((dy + y) >= dh) break
    if ((dy + y) < 0) continue

    ydy = y - sy + dy
    for (x=sx; x<(sx+w); x++) {
      pix = src[x,y]
      if ((pix != t) && (pix != "None")) {
        xdx = x - sx + dx

        # clip image on left/right
        if (xdx >= dw) break
        if (xdx < 0) continue

        # draw non-transparent pixel or else background
        #dst[xdx,ydy] = ((pix == t) || (pix == "None")) ? dst[xdx,ydy] : pix
        if ( (sa != 255) || (da != 255) )
          dst[xdx,ydy] = blend(src[x,y], dst[xdx,ydy], sa, da)
        else
          dst[xdx,ydy] = pix
      }
    }
  }
}

## draw image to terminal
function draw(src, xpos, ypos,    w,h, x,y, up,dn, line,screen) {
  w = src["width"]
  h = src["height"]

  for (y=0; y<h; y+=2) {
    if (y+ypos > terminal["height"]) break
    if (y+ypos < 0) continue

    prevup = prevdn = -1
    line = sprintf("\033[%0d;%0dH", y/2+ypos+1, xpos+1)
    for (x=0; x<w; x++) {
      if (x+xpos > terminal["width"]) break
      if (x+xpos < 0) continue

      up = src[x,y+0]
      dn = src[x,y+1]
      if ( (up != prevup) || (dn != prevdn) ) {
        line = line "\033[38;2;" up ";48;2;" dn "m"
        prevup = up
        prevdn = dn
      }
      line = line "▀"
    }
    screen = screen line "\033[0m"
  }
  bytes += length(screen)
  printf("%s", screen)


  if (debug) {
    fpselapsed = timex() - fpsstart
    fpsframes++

    if (fpselapsed >= 0.5) {
      printf("\033[1;1H")
      for (i=0; i<30; i++)
        printf("%s", hblock[clamp(int(window[i]*100)-8, 0,8) + 1] )
      printf("%.2ffps\033[K", fpsframes / fpselapsed)
  
      printf("\033[2;1H")
      for (i=0; i<30; i++)
        printf("%s", hblock[clamp(int(window[i]*100), 0,8) + 1] )
  
      tot = 0
      for (i=0; i<30; i++) tot += window[i]
      printf("(%.2f) elapsed: %5.1f\033[K", tot, elapsed)
  
      fpsstart = timex()
      fpsframes = 0
    }
  }
}

function delay(target,    skip, onesec, i, now, elapsed) {
  skip = 0
  onesec = 0
  oneframe = 1/target
  now = timex()

  # init sliding window
  if ( !(0 in window) ) {
    prev = now - oneframe
    for (i=0; i<target; i++)
      window[i] = oneframe
  }

  elapsed = now - prev

  # too slow, return number of frames to skip
  if ( elapsed > oneframe )
    skip = int( elapsed / oneframe )
  else {
    # calculate sliding FPS window
    for (i=1; i<target; i++)
      onesec += window[i]

    # do delay but no more than 2 frames
    while ( ((onesec + elapsed) < 1) && (elapsed < (oneframe*2)) ) {
      system("sleep 0.005")
      now = timex()
      elapsed = now - prev
    }
  }

  # update sliding FPS window
  for (i=0; i<(target-1); i++)
    window[i] = window[i+1]
  window[target-1] = elapsed

  prev = now

  return skip
}

