#!/usr/bin/env bash
# Helper for sesh-picker.sh's Ctrl+R binding. Receives the highlighted
# fzf line in "TARGET|DISPLAY" format, parses out the rename target,
# and opens tmux command-prompt pre-filled with the current name.
#
# Called from sesh-picker.sh AFTER fzf exits (via --expect=ctrl-r),
# so tmux has the real client context needed to render command-prompt.
#
# Behavior:
#   - Session row (TARGET = "homelab")           → rename-session
#   - Window row  (TARGET = "homelab:1")         → rename-window
#     (looks up the actual window name to use as the prompt's initial value)

set -uo pipefail

line="${1:-}"
[ -z "$line" ] && exit 0

target="${line%%|*}"
[ -z "$target" ] && exit 0

if [[ "$target" == *:* ]]; then
  # Window row: prefill with the window's actual name (not the index)
  current_name=$(tmux display-message -p -t "$target" '#{window_name}' 2>/dev/null)
  tmux command-prompt -p "rename window:" -I "$current_name" "rename-window -t '$target' '%%'"
else
  # Session row: prefill with the session name itself
  tmux command-prompt -p "rename session:" -I "$target" "rename-session -t '$target' '%%'"
fi
