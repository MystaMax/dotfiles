#!/usr/bin/env bash
# tmux session picker via sesh.
#
# Behaviour (Zellij-style):
#   - Lists tmux sessions + zoxide dirs + sesh.toml configs.
#   - Enter on an existing entry: sesh connect.
#   - Enter on a typed name with no match: create a fresh tmux session
#     with that name in $HOME and switch to it.
#   - Ctrl-D on a highlighted entry: tmux kill-session for that entry.
#
# Bound to `prefix + s` in ~/.config/tmux/tmux.conf.

set -uo pipefail

result=$(sesh list -t -z -c 2>/dev/null | fzf-tmux -p 60%,60% \
  --print-query \
  --no-sort \
  --ansi \
  --border-label ' sesh ' \
  --prompt '⚡  ' \
  --header '  enter: connect or create  |  ctrl-d: kill session' \
  --bind 'ctrl-d:execute(tmux kill-session -t {} 2>/dev/null || true)+reload(sesh list -t -z -c)' \
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
