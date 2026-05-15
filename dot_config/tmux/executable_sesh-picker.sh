#!/usr/bin/env bash
# tmux session picker via sesh.
#
# Default view: existing tmux sessions only (no zoxide noise).
# Use the in-picker keybindings to widen the search:
#   Ctrl-A   show all (tmux + zoxide + sesh.toml)
#   Ctrl-T   tmux sessions only (default)
#   Ctrl-X   zoxide directories only
#   Ctrl-D   kill the highlighted session
#   Enter    connect to selection, OR (if the query has no match)
#            create a new tmux session named after the typed query
#
# Bound to `prefix + s` in ~/.config/tmux/tmux.conf.

set -uo pipefail

result=$(sesh list -t 2>/dev/null | fzf-tmux -p 60%,60% \
  --print-query \
  --no-sort \
  --ansi \
  --preview '' \
  --border-label ' sesh ' \
  --prompt '⚡  ' \
  --header '  enter: connect/create  |  ctrl-d: kill  |  ^a all  ^t tmux  ^x zoxide' \
  --bind 'ctrl-a:change-prompt(⚡  all  )+reload(sesh list)' \
  --bind 'ctrl-t:change-prompt(⚡  tmux )+reload(sesh list -t)' \
  --bind 'ctrl-x:change-prompt(⚡  zox  )+reload(sesh list -z)' \
  --bind 'ctrl-d:execute(tmux kill-session -t {} 2>/dev/null || true)+reload(sesh list -t)' \
  || true)

# fzf --print-query writes the query on line 1 and any selection on line 2.
query=$(printf '%s\n' "$result" | sed -n '1p')
selection=$(printf '%s\n' "$result" | sed -n '2p')

if [ -n "$selection" ]; then
  exec sesh connect "$selection"
elif [ -n "$query" ]; then
  if tmux has-session -t="$query" 2>/dev/null; then
    exec sesh connect "$query"
  else
    tmux new-session -d -s "$query" -c "$HOME"
    exec tmux switch-client -t "$query"
  fi
fi
