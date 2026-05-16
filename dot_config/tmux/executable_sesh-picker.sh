#!/usr/bin/env bash
# tmux session picker — Zellij-style tree view.
#
# Default: shows all tmux sessions with their windows nested below
# as indented children. Type to filter across both. Picking:
#   - a session row     → switch to that session
#   - a window row      → switch session AND focus that window
#   - a typed-but-new   → create new session named after the query
#
# In-picker bindings:
#   Enter    switch / create
#   Ctrl-R   rename highlighted session/window via tmux command-prompt
#   Ctrl-D   end highlighted session OR window (killed via tmux)
#
# Each line is "TARGET|DISPLAY" — fzf shows DISPLAY (--with-nth=2..)
# but selection returns the full line so we can extract TARGET.
#
# Bound to `prefix + s` in ~/.config/tmux/tmux.conf.

set -uo pipefail

SCRIPT_PATH=~/.config/tmux/scripts/sesh-picker.sh
RENAME_HELPER=~/.config/tmux/scripts/picker-rename.sh

# Glyph bytes (match theme glyphs in ~/.config/tmux/themes/)
GH_FOLDER=$(printf '\xef\x84\x94')   # U+F114 folder (sessions)
GH_TERM=$(printf '\xef\x84\xa0')     # U+F120 terminal (windows)

list_tree() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null | while IFS= read -r session; do
    printf '%s|%s %s\n' "$session" "$GH_FOLDER" "$session"
    # TARGET uses window index so duplicate names are unambiguous;
    # display shows just the indented name (cleaner / matches Zellij).
    tmux list-windows -t "$session" -F '#{window_index}|#{window_name}' 2>/dev/null \
      | while IFS='|' read -r idx name; do
        printf '%s:%s|    %s\n' "$session" "$idx" "$name"
      done
  done
}

# Mode for fzf reload after kill: print just the tree, exit.
if [ "${1:-}" = "--tree" ]; then
  list_tree
  exit 0
fi

result=$(list_tree | fzf-tmux -p 60%,80% \
  --print-query \
  --expect=ctrl-r \
  --reverse \
  --no-sort \
  --ansi \
  --preview '' \
  --delimiter='|' \
  --with-nth=2.. \
  --border-label ' sesh ' \
  --prompt '⚡  ' \
  --header '  enter: switch/create  |  ctrl-r: rename  |  ctrl-d: end' \
  --bind "ctrl-d:execute(line={}; target=\${line%%|*}; if [[ \$target == *:* ]]; then tmux kill-window -t \"\$target\" 2>/dev/null; else tmux kill-session -t \"\$target\" 2>/dev/null; fi || true)+reload($SCRIPT_PATH --tree)" \
  || true)

# With --print-query AND --expect, fzf output is:
#   line 1: query
#   line 2: key pressed (empty if Enter)
#   line 3: selection
query=$(printf '%s\n' "$result" | sed -n '1p')
key=$(printf '%s\n' "$result" | sed -n '2p')
selection=$(printf '%s\n' "$result" | sed -n '3p')

# Ctrl-R was pressed → run the rename helper from outside the fzf popup
# context, so tmux command-prompt has a real client to render against.
if [ "$key" = "ctrl-r" ] && [ -n "$selection" ]; then
  exec "$RENAME_HELPER" "$selection"
fi

# Enter pressed (or any non-expected key)
if [ -n "$selection" ]; then
  target="${selection%%|*}"
  exec tmux switch-client -t "$target"
elif [ -n "$query" ]; then
  if tmux has-session -t="$query" 2>/dev/null; then
    exec tmux switch-client -t "$query"
  else
    tmux new-session -d -s "$query" -c "$HOME"
    exec tmux switch-client -t "$query"
  fi
fi
