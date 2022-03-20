#!/usr/bin/awk -f

# play a song through external application
function play(fname,    music, n, arr, mp3short) {
  n = split(mp3player, arr, "/")
  mp3short = arr[n]

  if (mp3short in mp3opts) {
    music = sprintf("%s "mp3opts[mp3short], mp3player, fname)
    print "" | music
  }
}

BEGIN {
  # options for supported mp3 players
  mp3opts["ffplay"]  = "-v -8 -nodisp -autoexit \"%s\" 1>/dev/null 2>&1"
  mp3opts["mpg123"]  = "--quiet --no-control \"%s\" 1>/dev/null 2>&1"
  mp3opts["cvlc"]    = "--quiet --play-and-exit \"%s\" 1>/dev/null 2>&1"
  mp3opts["mpv"]     = "--no-terminal \"%s\" 1>/dev/null 2>&1"
  mp3opts["mplayer"] = "-really-quiet \"%s\" 1>/dev/null 2>&1"

  # get start time and check if locale is correctly parsing floats
  start = timex()

  if (start != start+0) {
    print "Please run with \"export LC_NUMERIC=C\""
    print "Press [enter] to exit"
    getline
    exit 1
  }

  # get terminal width/height
  "stty size" | getline
  close("stty size")
  terminal["height"] = ($1 ? $1 : 24) * 2
  terminal["width"]  = ($2 ? $2 : 80)

  # create screen + fg+bg buffer (
  screen["width"]  = background["width"]   = foreground["width"]  = 80
  screen["height"] = background["height"]  = foreground["height"] = 50

  # check if terminal is big enough for our demo
  if ((terminal["width"] < screen["width"]) || (terminal["height"] < screen["height"])) {
    printf("Terminal size (%dx%d) is smaller than program size (%dx%d)\n", terminal["width"], terminal["height"], screen["width"], screen["height"])
    printf("Press [enter] to quit")
    getline
    exit 1
  }

  # check if we found a suitable external mp3 player
  if (mp3player == "false") {
    printf("Demo is a lot better with sound. Please install one of ffmpeg, mpg123, vlc, mpv or mplayer\n")
    printf("Press [enter] to continue music-less, or ctrl-c to quit")
    getline
  }

  # center output screen in middle of terminal
  xpos = int( (terminal["width"]  - screen["width"]) / 2)
  ypos = int( (terminal["height"] - screen["height"]) / 4) + 1

  # set scroll messages and timings
  scrollmsg[1]   = "     welcome to my little awk demo     "
  scrollmsg[2]   = "     ooh look at those lovely alpha blending objects     "
  scrollmsg[3]   = "     you did not think it was over yet, did you...     "
  scrollmsg[4]   = "     dont forget to give me a star on github and like on youtube     "

  scrollbegin[1] = 5.0
  scrolltime[1]  = 8.0

  scrollbegin[2] = 30.0
  scrolltime[2]  = 12.0

  scrollbegin[3] = 76.0
  scrolltime[3]  = 12.0

  scrollbegin[4] = 105.0
  scrolltime[4]  = 15.0

  ## close with an impossible start time
  scrollbegin[5] = 999

  # load font
  xpm3load("gfx/gods.xpm", godsfnt)
  godsfnt["font","charset"]="abcdefghijklmnopqrstuvwxyz<>.0123456789"

  # create scroller
  scroll["height"]      = godsfnt["height"]
  scroll["transparent"] = "0;0;0"
  scroll["alpha"]       = 176

  # initialize our demo effects
  init_metaballs()
  init_fire(screen)
  init_plasma()
  init_3d()
  init_starfield()

  # set layer transparency color to black
  foreground["transparent"] = "0;0;0"

  # start playing music
  play("music/Eggy Toast - Lose your head.mp3")

  # start main loop (song is 124sec long)
  while (elapsed <= 124) {
    # clear screen and buffers every frame
    clear(screen)
    clear(background)
    clear(foreground)

    ## do background stuff  
    if (( 0 <= elapsed) && (elapsed < 24))
      do_starfield(background)

    if ((24 <= elapsed) && (elapsed < 68))
      do_fire(background)

    # blend out fire background
    if ((60 <= elapsed) && (elapsed < 68))
      background["alpha"] = clamp(255 - (elapsed-60) * 32, 0,255)

    # reenable opacity
    if ((76 <= elapsed) && (elapsed < 78))
      background["alpha"] = 255

    if ((76 <= elapsed) && (elapsed < 124))
      do_plasma(background)


    ## do foreground stuff 
    if ((8 <= elapsed) && (elapsed < 76))
      do_3d(foreground)

    # do some blening on 3D objects
    if ((30 <= elapsed) && (elapsed < 60))
      foreground["alpha"] = clamp(glib["SIN",int(elapsed*30)%360]+64, 127,255)

    # reenable opacity
    if ((60 <= elapsed) && (elapsed < 68))
      foreground["alpha"] = 255

    # fade out 3D object
    if ((68 <= elapsed) && (elapsed < 76))
      foreground["alpha"] = clamp(int(255 - (elapsed-68) * 32), 0,255)

    # metaballs with alpha blending
    if ((84 <= elapsed) && (elapsed <= 124)) {
      do_metaballs(foreground)
      foreground["alpha"] = clamp(glib["SIN",int(elapsed*30)%360]+64, 127,255)
    }


    # copy background and foreground to screen buffer
    copy(screen, background, 0,0, 0,0) 
    copy(screen, foreground, 0,0, 0,0) 


    # text scroller is always blending in and out
    scroll["alpha"] = clamp(glib["SIN",int(elapsed*100)%360]+64, 127,255)

    # loop through scroller messages
    if (scrollbegin[msgcnt+1] <= elapsed) {
      msgcnt++
      scroll["width"] = length(scrollmsg[msgcnt]) * 16
      clear(scroll)
      write(scroll, godsfnt, scrollmsg[msgcnt])
      scrollstart = timex()
    }

    scrollelapsed = timex() - scrollstart

    # copy scroller to screen
    if (scrollelapsed < scrolltime[msgcnt]) {
      srcx = int(scrollelapsed*70)

      if (srcx < (scroll["width"]-screen["width"]) ) {
        # first message is flat
        if (msgcnt == 1) 
          copy(screen, scroll, 0,int( (screen["height"]-scroll["height"]) / 2), srcx,0 )
        else {
          # other messages are sine wavey
          for (x=0; x<screen["width"]; x++) {
            s = glib["SIN",(elapsed*100)%360] / 255 + 4
            mysine = int( glib["sin",(elapsed*100)%360] / 30 ) + int( glib["sin",int(x*s)%360] / -30) + 17
            copy(screen, scroll, x,mysine, srcx+x,0, 1,scroll["height"])
          }
        }
      }
    }

    # slow down to 30 fps and draw frame
    delay(fps)
    draw(screen, xpos,ypos)
    frames++
    elapsed = timex() - start
  }

  # human readable data units
  split("K M G T", units)
  for (hbytes=bytes; hbytes > 1000; hunits++) { hbytes /= 1000 }
  for (tbytes=bytes/elapsed; tbytes > 1000; tunits++) { tbytes /= 1000 }

  # print some basic throughput stats
  printf("\n\033[0m%d frames (%.1ffps avg)\n%.1f%cBytes (%.1f%cB/s)\n", frames, frames/elapsed, hbytes, units[hunits], tbytes, units[tunits])
  printf("Press [enter] to exit")
  getline
}

