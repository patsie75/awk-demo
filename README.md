Old Skool demo in AWK

Since I have been making all kinds of different graphical things in awk, I thought it would be time for me to finally try and make a real old-skool demo. So I got some of my better looking effects, made sure they worked in all major awk releases (gawk, mawk and nawk), slapped some timing code on it and voila, here's my first demo!

Code that I've done before and reused after serious modifications
  o https://github.com/patsie75/awk-plasma
  o https://github.com/patsie75/awk-fire
  o https://github.com/patsie75/awk-3d
  o https://github.com/patsie75/awk-glib

The startfield and metaballs effect were not published previously and made especially for this demo

Dependencies:
  o A relatively recent and fast enough CPU (duh!)
  o A terminal with good UTF-8 and true-color/24-bit ANSI support
    - Gnome Terminal (some other LibVTE based terminals might also work, like Termit)
    - xterm
    x mlterm ran into an issue (https://github.com/arakiken/mlterm/issues/39)
  o A recent version of a modern awk (tested with):
    - mawk (1.3.3 and 1.3.4)
    - gawk (all versions from 4.1.4 till 5.1.1)
    - nawk (20121220)
    x busybox awk technically works, but the performance I got was horrible
  o If you want music to accompany the visual effects, one of the following:
    - ffplay (part of ffmpeg)
    - mpg123
    - cvlc (part of vlc)
    - mpv
    - mplayer

Credits:
 - Music (Lose Your Head) by Eggy Toast, used under the Creative Commons License (https://creativecommons.org/licenses/by-nc-sa/4.0/)
   https://freemusicarchive.org/music/eggy-toast/game-music/lose-your-headmp3

