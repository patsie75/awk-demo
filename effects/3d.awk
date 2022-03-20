function between(value, a, b) { return ((value >= a) && (value < b)) }
function abs(i) { return( (i<0) ? -i : i ) }
function max(a,b) { return( (a>b) ? a : b ) }
function min(a,b) { return( (a<b) ? a : b ) }

function vector(v, x,y,z) { v["x"] = x; v["y"] = y; v["z"] = z; }

function crossProduct(n, a,b,    l) {
  n["x"] = a["y"] * b["z"] - a["z"] * b["y"]
  n["y"] = a["z"] * b["x"] - a["x"] * b["z"]
  n["z"] = a["x"] * b["y"] - a["y"] * b["x"]

  l = sqrt(n["x"]*n["x"] + n["y"]*n["y"] + n["z"]*n["z"])

  n["x"] /= l ? l : 1
  n["y"] /= l ? l : 1
  n["z"] /= l ? l : 1
}

function shade(col, colnum, shades, percent,    rgb, i) {
  if (split(col, rgb, ";") == 3) {
    for (i=0; i<shades; i++) {
      colors3d[colnum,i] = sprintf("%s;%s;%s", \
        int(rgb[1] - (rgb[1] * (percent/100) * i/shades)), \
        int(rgb[2] - (rgb[2] * (percent/100) * i/shades)), \
        int(rgb[3] - (rgb[3] * (percent/100) * i/shades)) \
      )
    }
    colors3d[colnum] = shades
  } else return -1
}


function animate(starttime) {
  elapsed = timex() - starttime

  if (between(elapsed,  0,  5)) { cam["drawmode"] = 0 }
  if (between(elapsed,  5, 10)) { cam["drawmode"] = 2 }
  if (between(elapsed, 10, 15)) { cam["drawmode"] = 3 }
  if (between(elapsed, 15, 20)) { cam["drawmode"] = 3 }
  if (between(elapsed, 20, 25)) { cam["drawmode"] = 3 }
  if (between(elapsed, 25, 30)) { cam["drawmode"] = 3 }
  if (elapsed > 35) exit 0
}

## Draw a pixel of color "col" on position (x,y) on "canvas"
function pixel(dst, x, y, col) {
  if ((0 <= x && x < dst["width"]) && (0 <= y && y < dst["height"]))
    dst[int(x),int(y)] = col
}

## Draw a horizontal line from (x1,y1) and length len
function hline(dst, x1,y1, len, col,   i, l) {
  l = int(x1+len)
  for (i=x1; i<l; i++)
    pixel(dst, i,y1, col)
}

## Draw a line from (x1,y1) to (x2,y2)
function line2d(dst, x1,y1,x2,y2, col,   direction, a1,a2,b1,b2, tmp, i,j, m) {
  if (abs(x1-x2) >= abs(y1-y2)) {
    # horizontal line
    direction = 1
    a1=x1; a2=x2; b1=y1; b2=y2
  } else {
    # vertical line
    direction = 0
    a1=y1; a2=y2; b1=x1; b2=x2
  }

  # swap points if a1 > a2
  if (a1 > a2) {
    tmp=a1; a1=a2; a2=tmp
    tmp=b1; b1=b2; b2=tmp
  }

  # calculate slope/delta
  m = (a2-a1) ? (b2-b1) / (a2-a1) : 0

  j = b1
  # draw either a "horizontal" or "vertical" line
  if (direction) {
    for (i=a1; i<=a2; i++) {
      #pixel(dst, direction ? i : j, direction ? j : i, col)
      pixel(dst, i, j, col)
      j += m
    }
  } else {
    for (i=a1; i<=a2; i++) {
      pixel(dst, j, i, col)
      j += m
    }
  }
}

## Draw a triangle (x1,y1), (x2,y2), (x3,y3)
function triangle(dst, x1,y1, x2,y2, x3,y3, col) {
  line2d(dst, x1,y1, x2,y2, col)
  line2d(dst, x2,y2, x3,y3, col)
  line2d(dst, x3,y3, x1,y1, col)
}

### draw a filled triangle (x1,y1), (x2,y2), (x3,y3)
function fillTriangle(dst, x1,y1, x2,y2, x3,y3, col,    i, d1,d2,d3, sx,ex) {
  if ((x1 < 0) && (x2 < 0) && (x3 < 0)) return
  if ((y1 < 0) && (y2 < 0) && (y3 < 0)) return
  if ((x1 > dst["width"])  && (x2 > dst["width"])  && (x3 > dst["width"]))  return
  if ((y1 > dst["height"]) && (y2 > dst["height"]) && (y3 > dst["height"])) return

  # y1 < y2 < y3
  if (y2 < y1) { i=y1; y1=y2; y2=i; i=x1; x1=x2; x2=i }
  if (y3 < y2) { i=y2; y2=y3; y3=i; i=x2; x2=x3; x3=i }
  if (y2 < y1) { i=y1; y1=y2; y2=i; i=x1; x1=x2; x2=i }

  # get delta/slopes
  i = y2-y1; d1 = i ? (x2-x1) / i : 0
  i = y3-y2; d2 = i ? (x3-x2) / i : 0
  i = y1-y3; d3 = i ? (x1-x3) / i : 0

  # upper triangle
  for (i=y1; i<y2; i++) {
    sx = x1 + (i-y1) * d3
    ex = x1 + (i-y1) * d1

    if (sx < ex) {
      hline(dst, sx,i, (ex-sx)+1, col)
    } else {
      hline(dst, ex,i, (sx-ex)+1, col)
    }
  }

  # lower triangle
  for(i=y2; i<=y3; i++) {
    sx = x1 + (i-y1) * d3
    ex = x2 + (i-y2) * d2

    if (sx < ex) {
      hline(dst, sx,i, (ex-sx)+1, col)
    } else {
      hline(dst, ex,i, (sx-ex)+1, col)
    }
  }
}

function variable(value, vararr,   v, neg) {
  v = value
  neg = 0

  ## just a number
  if (v == v+0) return(v)

  ## negative variable
  if (substr(v,1,1) == "-") {
    neg = 1
    v = substr(v,2)
  }

  # return variable content or 0
  if (v in vararr)
    return neg ? -vararr[v] : vararr[v]
  else return v
}


function loadmesh(mesh, file,   var, linenr, v, e, t) {
  linenr = v = e = t = 0

  while ((getline < file) > 0) {
    linenr++

    if ( (NF > 0) && ($1 !~ /^(#|;)/) ) {

      if ($1 == "var") {
        if (NF == 3) var[$2] = $3
        else printf("Error line #%d: syntax error: \"var <variable> <value>\"\n", linenr)

      } else if ($1 == "col") {
        if (NF == 3) {
          shade($3, $2, nrshades, darkness)
	} else printf("Error line #%d: syntax error: \"col <r;g;b> <colornr>\"\n", linenr)

      } else if ($1 == "vert") {
        if (NF == 4) {
          v++
          mesh["vert",v,"x"] = variable($2, var)
          mesh["vert",v,"y"] = variable($3, var)
          mesh["vert",v,"z"] = variable($4, var)
        } else printf("Error line #%d: syntax error: \"vert <x> <y> <z>\"\n", linenr)
  
      } else if ($1 == "tri") {
        if ((NF == 4) || (NF == 5)) {
          t++
          mesh["tri",t,1] = variable($2, var)
          mesh["tri",t,2] = variable($3, var)
          mesh["tri",t,3] = variable($4, var)
          mesh["tri",t,"color"] = (NF == 5) ? variable($5, var) : 7
        } else printf("Error line #%d: syntax error: \"tri <vertex1> <vertex2> <vertex3> [<color>]\"\n", linenr)

      } else {
        printf("Error line #%d: unknown keyword \"%s\"\n", linenr, $1)
      }
    }
  }
  mesh["vertices"] = v
  mesh["tris"] = t
}

function drawmesh(dst, mesh, cam,    v, dx,dy,dz, zx,zy,yx,yz,xy,xz, px,py, v1,v2,v3, xrotoffset,yrotoffset,zrotoffset, xpos,ypos,zpos) {
  cam["move","z"] = 1 / cam["loc","z"]

  # calculate screen coordinates of each vertex
  for (v=1; v<=mesh["vertices"]; v++) {
    # delta from pivot point
    dx = (mesh["vert",v,"x"] - cam["piv","x"])
    dy = (mesh["vert",v,"y"] - cam["piv","y"])
    dz = (mesh["vert",v,"z"] - cam["piv","z"])

    zx = dx * cos(cam["angle","z"]) - dy * sin(cam["angle","z"]) - dx
    zy = dx * sin(cam["angle","z"]) + dy * cos(cam["angle","z"]) - dy

    yx = (dx+zx) * cos(cam["angle","y"]) - dz * sin(cam["angle","y"]) - (dx+zx)
    yz = (dx+zx) * sin(cam["angle","y"]) + dz * cos(cam["angle","y"]) - dz

    xy = (dy+zy) * cos(cam["angle","x"]) - (dz+yz) * sin(cam["angle","x"]) - (dy+zy)
    xz = (dy+zy) * sin(cam["angle","x"]) + (dz+yz) * cos(cam["angle","x"]) - (dz+yz)

    xrotoffset = yx + zx
    yrotoffset = zy + xy
    zrotoffset = xz + yz

    # screenspace coordinates
    zpos[v] = (mesh["vert",v,"z"] + zrotoffset + cam["loc","z"])
    xpos[v] = (mesh["vert",v,"x"] + xrotoffset + cam["loc","x"]) / zpos[v] / cam["move","z"] + cam["move","x"]
    ypos[v] = (mesh["vert",v,"y"] + yrotoffset + cam["loc","y"]) / zpos[v] / cam["move","z"] + cam["move","y"]
  }

  # drawmode: triangles or filled triangle
  if ((cam["drawmode"] == 3) || (cam["drawmode"] == 2)) {
    delete painter

    # loop over all triangles
    for (t=1; t<=mesh["tris"]; t++) {
      v1 = mesh["tri",t,1]
      v2 = mesh["tri",t,2]
      v3 = mesh["tri",t,3]

      # is triangle within view-space?
      if ( (xpos[v1] < 0) && (xpos[v2] < 0) && (xpos[v3] < 0) ) continue
      if ( (ypos[v1] < 0) && (ypos[v2] < 0) && (ypos[v3] < 0) ) continue
      if ( (xpos[v1] > dst["width"] ) && (xpos[v2] > dst["width"] ) && (xpos[v3] > dst["width"] ) ) continue
      if ( (ypos[v1] > dst["height"]) && (ypos[v2] > dst["height"]) && (ypos[v3] > dst["height"]) ) continue

      # Get any two lines of the vertex for cross product calculation
      line1["x"] = xpos[v2] - xpos[v1]
      line1["y"] = ypos[v2] - ypos[v1]
      line1["z"] = zpos[v2] - zpos[v1]

      line2["x"] = xpos[v3] - xpos[v1]
      line2["y"] = ypos[v3] - ypos[v1]
      line2["z"] = zpos[v3] - zpos[v1]

      # Calculate the cross product (for z-axis normal)
      crossProduct(n, line1,line2)

      # if the z-axis normal is facing the camera, add it to the to-draw array
      if (n["z"] < 0) {
        mesh["tri",t,"normal","z"] = n["z"]
        painter[t] = (zpos[v1] + zpos[v2] + zpos[v3]) / 3
      }
    }

    # to-draw array
    for (t in painter) {
      v1 = mesh["tri",t,1]
      v2 = mesh["tri",t,2]
      v3 = mesh["tri",t,3]

      # get primairy color and calculate shade of color from angle of z-axis normal
      colpri = mesh["tri",t,"color"]
      colsub = colors3d[colpri] - int( abs(mesh["tri",t,"normal","z"] + 0.5) * colors3d[colpri] ) - 1

      if (cam["drawmode"] == 2) {
#        fillTriangle(dst, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], "1;1;1" )
        triangle(dst, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], colors3d[colpri,colsub] )
      }
      if (cam["drawmode"] == 3)
        fillTriangle(dst, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], colors3d[colpri,colsub] )
    }
  }
}

function init_3d() {
  ## prepare color shades
  nrshades = 64
  darkness = 55

  shade(      "0;0;0", "0", nrshades, darkness)
  shade(    "255;0;0", "1", nrshades, darkness)
  shade(    "0;255;0", "2", nrshades, darkness)
  shade(  "255;255;0", "3", nrshades, darkness)
  shade(    "0;0;255", "4", nrshades, darkness)
  shade(  "255;0;255", "5", nrshades, darkness)
  shade(  "0;255;255", "6", nrshades, darkness)
  shade("255;255;255", "7", nrshades, darkness)

  ## set up viewmode variables
  cam["drawmode"] = 3; # 0 == vertices; 1 == edges; 2 == triangles; 3 == filled triangles

  ## set camera values
  cam["move","x"] = width/2
  cam["move","y"] = height/2
  cam["move","z"] = 0

  cam["loc","x"] = 0
  cam["loc","y"] = 0
  cam["loc","z"] = 400

  cam["angle","x"] = 0
  cam["angle","y"] = 0
  cam["angle","z"] = 0

  cam["piv","x"] = 0
  cam["piv","y"] = 0
  cam["piv","z"] = 0

  ## load 3D object
  loadmesh(mesh, "gfx/pyramid.mesh")
  object = 1
}

function do_3d(buf) {
  if ((8 <= elapsed) && (elapsed < 24)) {
    cam["drawmode"] = 2
    cam["loc","y"] = int(buf["height"] / 2)
    cam["loc","x"] = int(buf["width"] / 2)
    cam["angle","y"] = sin(elapsed) * 2
  }

  if ((16 <= elapsed) && (elapsed < 24)) {
    # spin all axis
    cam["angle","x"] = cos(elapsed) * 3
    cam["angle","y"] = sin(elapsed) * 2
    cam["angle","z"] = sin(elapsed*2)
  }

  if ((24 <= elapsed) && (elapsed < 76)) {
    # solid object
    cam["drawmode"] = 3

    # spin all axis
    cam["angle","x"] = cos(elapsed) * 3
    cam["angle","y"] = sin(elapsed) * 2
    cam["angle","z"] = sin(elapsed*2)

    # move camera
    cam["loc","y"] = sin(elapsed * -2) * buf["height"] / 4 + int(buf["height"] / 2)
    cam["loc","x"] = cos(elapsed) * buf["width"] / 2 + int(buf["width"] / 2)
  }

  if ((35 <= elapsed) && (elapsed < 50) && (object != 2)) {
    loadmesh(mesh, "gfx/cube.mesh")
    object = 2
  }

  if ((50 <= elapsed) && (elapsed < 76) && (object != 3)) {
    loadmesh(mesh, "gfx/dodecahedron.mesh")
    object = 3
  }

  clear(buf)
  drawmesh(buf, mesh, cam)
}

