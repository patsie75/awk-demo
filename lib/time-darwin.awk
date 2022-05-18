## get timestamp with one-hundreth of a second precision
function timex() {
  "sysctl -n machdep.time_since_reset" | getline
  close("sysctl -n machdep.time_since_reset")
  return $1/24000000
}
