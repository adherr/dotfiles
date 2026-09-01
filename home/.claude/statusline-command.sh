#!/usr/bin/env bash
# Claude Code status line - inspired by Starship prompt config

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ── LEFT SIDE: context window info ──────────────────────────────────────────

left=""

# Context window used %
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  used_int=${used_int:-0}
  if [ "$used_int" -ge 80 ]; then
    color='\033[0;31m'   # red
  elif [ "$used_int" -ge 50 ]; then
    color='\033[0;33m'   # yellow
  else
    color='\033[0;32m'   # green
  fi
  left+="$(printf "${color}ctx: ${used_pct}%%\033[0m")"
fi


# Model (dim)
if [ -n "$model" ]; then
  left+=" $(printf '\033[2m[%s]\033[0m' "$model")"
fi

# Claude 5-hour rate limit usage (% used, counting up + reset time), from
# the statusline payload itself - no external CLI/cache needed.
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$five_hour_used" ] && [ -n "$five_hour_resets" ]; then
  five_hour_used_int=${five_hour_used%.*}
  if [ "$five_hour_used_int" -ge 80 ]; then
    usage_color='\033[0;31m'   # red
  elif [ "$five_hour_used_int" -ge 50 ]; then
    usage_color='\033[0;33m'   # yellow
  else
    usage_color='\033[0;32m'   # green
  fi
  reset_time=$(date -j -f "%s" "$five_hour_resets" "+%H:%M" 2>/dev/null)
  left+=" $(printf "${usage_color}${five_hour_used_int}%%\033[0m")"
  if [ -n "$reset_time" ]; then
    left+="$(printf "\033[2m → ${reset_time}\033[0m")"
  fi
fi

# ── RIGHT SIDE: git branch ───────────────────────────────────────────────────

right=""

# Git branch (yellow, truncated to 40 chars)
git_dir="${cwd:-$(pwd)}"
git_branch=""
if git -C "$git_dir" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$git_dir" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || git -C "$git_dir" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
  git_branch="${git_branch:0:40}"
fi
if [ -n "$git_branch" ]; then
  right+="$(printf '\033[0;33mon %s\033[0m' "$git_branch")"
fi

# PR for the current branch, via `gh pr view` (GitHub CLI). Cached per
# repo+branch in the background so the statusline never blocks on the
# network call. Appended after the branch, on the same line, if it fits.
pr_segment=""
if [ -n "$git_branch" ] && command -v gh > /dev/null 2>&1; then
  pr_cache_key=$(printf '%s|%s' "$git_dir" "$git_branch" | shasum | cut -d' ' -f1)
  pr_cache="${TMPDIR:-/tmp}/claude-statusline-pr-${pr_cache_key}.json"
  pr_cache_max_age=60
  pr_cache_age=9999
  if [ -f "$pr_cache" ]; then
    pr_cache_age=$(( $(date +%s) - $(stat -f %m "$pr_cache" 2>/dev/null || echo 0) ))
  fi
  if [ "$pr_cache_age" -ge "$pr_cache_max_age" ]; then
    ( cd "$git_dir" && (timeout 3 gh pr view --json number,url,isDraft 2>/dev/null || echo '{}') > "${pr_cache}.tmp" && mv "${pr_cache}.tmp" "$pr_cache" ) > /dev/null 2>&1 &
    disown 2>/dev/null
  fi
  pr_json=$(cat "$pr_cache" 2>/dev/null)
  pr_number=$(printf '%s' "$pr_json" | jq -r '.number // empty')
  pr_url=$(printf '%s' "$pr_json" | jq -r '.url // empty')
  pr_draft=$(printf '%s' "$pr_json" | jq -r '.isDraft // false')
  if [ -n "$pr_number" ]; then
    if [ "$pr_draft" = "true" ]; then
      pr_text="$(printf '\033[2mdraft PR #%s\033[0m' "$pr_number")"
    else
      pr_text="$(printf '\033[0;36mPR #%s\033[0m' "$pr_number")"
    fi
    if [ -n "$pr_url" ]; then
      pr_text="$(printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$pr_url" "$pr_text")"
    fi
    pr_segment=" $pr_text"
  fi
fi

# ── LAYOUT: left-align left, right-align right ──────────────────────────────

# Strip ANSI codes to measure plain text lengths
strip_ansi() { printf '%s' "$1" | perl -pe 's/\x1b\[[0-9;]*m//g; s/\x1b\]8;;.*?\x1b\\//g'; }

# Claude Code's status box renders narrower than the full terminal width
# (border/padding), so reserve a margin or the right side gets clipped.
margin=4
term_width=$(( $(tput cols 2>/dev/null || echo 80) - margin ))

left_plain=$(strip_ansi "$left")
left_len=${#left_plain}

# Only tack the PR on if branch + PR still fits; otherwise just the branch.
right_with_pr="${right}${pr_segment}"
right_with_pr_plain=$(strip_ansi "$right_with_pr")
if [ $(( term_width - left_len - ${#right_with_pr_plain} )) -ge 1 ]; then
  right="$right_with_pr"
fi

right_plain=$(strip_ansi "$right")
right_len=${#right_plain}

padding=$(( term_width - left_len - right_len ))
if [ "$padding" -lt 1 ]; then
  # Not enough room for both sides; drop the right side rather than let it
  # get truncated mid-string by the UI.
  right=""
  padding=$(( term_width - left_len ))
  if [ "$padding" -lt 1 ]; then
    padding=1
  fi
fi

printf '%s%*s%s' "$left" "$padding" "" "$right"
