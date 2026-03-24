#!/bin/sh

mount="/"
warning=20
critical=10

emit_df() {
  df -h -P -l "$mount" | awk -v warning="$warning" -v critical="$critical" '
NR == 2 {
  text = $4
  tooltip = "Filesystem: " $1 "\\rSize: " $2 "\\rUsed: " $3 "\\rAvail: " $4 "\\rUse%: " $5 "\\rMounted on: " $6
  use = $5
}

END {
  class = ""
  gsub(/%$/, "", use)

  if ((100 - use) < critical) {
    class = "critical"
  } else if ((100 - use) < warning) {
    class = "warning"
  }

  print "{\"text\":\"" text "\", \"percentage\":" use ",\"tooltip\":\"" tooltip "\", \"class\":\"" class "\"}"
}
'
}

fs_type="$(findmnt -n -o FSTYPE --target "$mount" 2>/dev/null)"

# Fallback when findmnt is unavailable.
if [ -z "$fs_type" ]; then
  fs_type="$(stat -f -c %T "$mount" 2>/dev/null)"
fi

if [ "$fs_type" = "btrfs" ] && command -v btrfs >/dev/null 2>&1; then
  if ! btrfs filesystem usage -b "$mount" 2>/dev/null | awk -v warning="$warning" -v critical="$critical" -v mount="$mount" '
function human(bytes, value, unit, units, i) {
  split("B KiB MiB GiB TiB PiB EiB", units, " ")
  value = bytes + 0
  i = 1
  while (value >= 1024 && i < 7) {
    value = value / 1024
    i++
  }
  unit = units[i]
  if (i == 1) {
    return sprintf("%d %s", value, unit)
  }
  return sprintf("%.1f %s", value, unit)
}

/^[[:space:]]*Device size:/ {
  size = $3
}
/^[[:space:]]*Used:/ {
  used = $2
}
/^[[:space:]]*Free \(estimated\):/ {
  avail = $3
}

END {
  if (size == "" || used == "" || avail == "") {
    exit 1
  }

  use = int((used * 100 / size) + 0.5)
  avail_percent = 100 - use
  class = ""

  if (avail_percent < critical) {
    class = "critical"
  } else if (avail_percent < warning) {
    class = "warning"
  }

  text = human(avail)
  tooltip = "Filesystem: btrfs\\rSize: " human(size) "\\rUsed: " human(used) "\\rAvail: " human(avail) "\\rUse%: " use "%\\rMounted on: " mount
  print "{\"text\":\"" text "\", \"percentage\":" use ",\"tooltip\":\"" tooltip "\", \"class\":\"" class "\"}"
}
'
  then
    emit_df
  fi
else
  emit_df
fi
