#!/usr/bin/env bash
shopt -s nullglob

## leave a workable terminal on exit
cleanup() { printf "\033[?25h\033[?1049l"; }
trap cleanup EXIT

## find suitable awk version
for awkshort in ${awk:-mawk gawk nawk awk}; do
  awkbin=$(type -P "$awkshort") && break
done
if [[ -z "$awkbin" ]]; then
  printf "No suitable awk found\n" >&2
  exit 1
fi

## find suitable mp3 player
for mp3short in ${mp3player:-ffplay mpg123 cvlc mpv mplayer}; do
  mp3bin=$(type -P "$mp3short") && break
done

## add specific awk options here
declare -A opts
opts=( [gawk]="-pdemo.prof" )

## add specific awk includes here
declare -A incs
incs=( [gawk]="-flib/hex.gawk" [gawk500]="-flib/hex.gawk" [gawk511]="-flib/hex.gawk" [mawk]="-flib/hex.awk" [mawk133]="-flib/hex.awk" [nawk]="-flib/hex.awk" [awk]="-flib/hex.awk" [bbawk]="-flib/hex.awk" )

## find all effects to include
effects=( effects/*.awk )
if [[ ${#effects[@]} -eq 0 ]]; then
  printf "No effects found\n" >&2
  exit 1
fi

## start program
# hide cursor and set alternative terminal buffer
printf "\033[?25l\033[?1049h"

# start program
LC_NUMERIC=C "$awkbin" ${opts[$awkshort]} -v debug="${debug:-0}" -v fps="${fps:-30}" -v mp3player="${mp3bin:-false}" "${effects[@]/#/-f}" ${incs[$awkshort]} -f lib/xpm3.awk -f lib/glib.awk -f demo.awk
