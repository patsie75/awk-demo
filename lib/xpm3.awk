BEGIN {
  # generate color pallet
  cmd = "convert -list color 2>/dev/null"
  while ((cmd | getline) > 0)
    #if ( match($2, /srgb\(([0-9]+),([0-9]+),([0-9]+)\)/, arr) )
    if ( $2 ~ /srgb\(([0-9]+),([0-9]+),([0-9]+)\)/ ) {
      gsub(/srgb\(|\)/, "", $2)
      split($2, arr, ",");
      pallet[$1] = sprintf("%d;%d;%d", arr[1], arr[2], arr[3])
    }
  close(cmd)

  hexdigits = "0123456789abcdef"
}

function xpm3load(fname, dst,    a, width, height, numcols, charsppx, color, c, data, i, j, line, pix) {
  while ((getline <fname) > 0) {
    # ignore comments
    if ($1 == "/*")
      continue

    # read width, height, colors and characters per pixel
    #if ( match($0, /"([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s*"/, a) ) {
    if ($0 ~ /"([0-9]+) +([0-9]+) +([0-9]+) +([0-9]+) *"/) {
      gsub(/[,"]/, "", $0)
      width    = int($1)
      height   = int($2)
      numcols  = int($3)
      charsppx = int($4)
      continue
    }


    # map chars to colors
    #if ( match($0, /"(.+) c ([^"]+)",/, a) ) {
    if ($0 ~ /"(.+) c ([^"]+)",/) {
      gsub(/^"|",?$/, "", $0)
      col = substr($0, 1, charsppx)
      if ($3 in pallet) {
        color[col] = pallet[$3]
      } else {
        #if ( match(a[2], /#(..)(..)(..)/, c) )
        if ($3 ~ /#(..)(..)(..)/ ) {
          c[1] = substr($3, 2,2)
          c[2] = substr($3, 4,2)
          c[3] = substr($3, 6,2)
          color[col] = hex("0x"c[1]) ";" hex("0x"c[2]) ";" hex("0x"c[3])
        } else color[col] = $3
      }
      continue
    }

    # get pixel data
    #if ( match($0, /"(.{96})",?/, a) )
    if ( $0 ~ /".+",?/ ) {
      gsub(/^"|",?$/, "", $0)
      data[i++] = $0
    }

  }

  close(fname)

  # convert pixel data to colors
  for (j=0; j<height; j++) {
    line = data[j]
    for (i=0; i<width; i++) {
      pix = substr(line, (i*charsppx)+1, charsppx)
      if (pix in color)
        dst[i,j] = color[pix]
      else {
        printf("xpm3::load(): Could not find color \"%s\" in color[] on line #%d (pos %d)\n", pix, j, i)
        return 0
      }
    }
  }

  dst["width"]  = width
  dst["height"] = height

  return 1
}

# Convert string of hex digits (optionally prefixed with "0x") to number.
function hex(str,    n, i, digit) {
  str = tolower(str)
  if (substr(str, 1, 1) == "-")
    return -hex(substr(str, 2))
  if (substr(str, 1, 2) == "0x")
    str = substr(str, 3)
  n = 0
  for (i=1; i<=length(str); i++) {
    digit = index(hexdigits, substr(str, i, 1))
    if (digit == 0)
      return n
    n = n*16 + digit-1
  }
  return n
}
