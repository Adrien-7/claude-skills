#!/bin/bash
input=$(cat)

# PS1-derived prompt: \u@\h:\w (colors from ~/.bashrc PS1)
ps1_user=$(whoami)
ps1_host=$(hostname -s)
ps1_cwd=$(basename "$(echo "$input" | jq -r '.workspace.current_dir // empty')")
ps1_out=$(printf '\033[01;32m%s@%s\033[00m:\033[01;34m%s\033[00m' "$ps1_user" "$ps1_host" "$ps1_cwd")

# Model name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Effort hint (only present when the model supports reasoning effort)
effort=$(echo "$input" | jq -r '.effort.level // empty')

# Context usage percentage (pre-calculated)
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build progress bar (10 chars wide)
build_bar() {
  local pct="$1"
  local width=10
  local filled=$(echo "$pct $width" | awk '{printf "%d", ($1/100)*$2 + 0.5}')
  local empty=$(( width - filled ))
  local bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  echo "$bar"
}

# Rate limits
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Assemble output
out="$ps1_out"

# Model
if [ -n "$model" ]; then
  [ -n "$out" ] && out="$out "
  out="$out$(printf '\033[01;36m%s\033[00m' "$model")"
fi

# Effort hint
if [ -n "$effort" ]; then
  [ -n "$out" ] && out="$out "
  out="$out$(printf '\033[00;90m(%s)\033[00m' "$effort")"
fi

# Context bar
if [ -n "$used_pct" ]; then
  bar=$(build_bar "$used_pct")
  used_rounded=$(printf '%.0f' "$used_pct")
  out="$out $(printf '\033[00;33m[%s]\033[00m \033[00;33m%s%%\033[00m' "$bar" "$used_rounded")"
fi

# Rate limits
limits=""
if [ -n "$five_pct" ]; then
  limits="5h:$(printf '%.0f' "$five_pct")%"
fi
if [ -n "$week_pct" ]; then
  [ -n "$limits" ] && limits="$limits "
  limits="${limits}7d:$(printf '%.0f' "$week_pct")%"
fi
if [ -n "$limits" ]; then
  out="$out $(printf '\033[00;35m%s\033[00m' "$limits")"
fi

printf '%s' "$out"
