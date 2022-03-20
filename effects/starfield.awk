function init_starfield(    i) { 
  for (i=0; i<100; i++) {
    star[i,"x"] = int(rand() * 80) - 40
    star[i,"y"] = int(rand() * 60) - 30
    star[i,"z"] = int(rand() * 254) + 1
  }
}

function do_starfield(buf,     w,h,i,x,y,c) {
  w = buf["width"]
  h = buf["height"]

  if ((0 <= elapsed) && (elapsed < 4)) {
    xvel = 0.5
    yvel = 0.0
    zvel = 0.0
  } else if ((4 <= elapsed) && (elapsed < 12)) {
    zvel -= 0.01
    zvel = clamp(zvel, -1.0,0)
  } else if ((12 <= elapsed) && (elapsed < 24)) {
    xvel = glib["sin",int(elapsed*30) % 360] / 1023
    yvel = glib["sin",int(elapsed*50) % 360] / 1023
    zvel = -1.0
  }

  # update and draw stars
  for (i=0; i<50; i++) {
    # move stars in x, y and z axis
    star[i,"x"] += xvel
    star[i,"y"] += yvel
    star[i,"z"] += zvel

    # calculate screen (x,y) coordinates and color
    x = int(star[i,"x"] * 255 / star[i,"z"]) + 40
    y = int(star[i,"y"] * 255 / star[i,"z"]) + 30
    c = clamp(255 - star[i,"z"], 0,255)

    # put star on buffer/screen
    buf[x,y] = sprintf("%d;%d;%d", c,c,c)

    # if star is offscreen, wrap around
    if (x > w) star[i,"x"] -= w
    if (x < 0) star[i,"x"] += w
    if (y > h) star[i,"y"] -= h
    if (y < 0) star[i,"y"] += h
    if (star[i,"z"] > 255) star[i,"z"] -= 255
    if (star[i,"z"] <= 0) star[i,"z"] += 255
  }
}
