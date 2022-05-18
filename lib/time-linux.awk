## get timestamp with one-hundreth of a second precision
function timex() {
  getline <"/proc/uptime"
  close("/proc/uptime")
  return $1
}

