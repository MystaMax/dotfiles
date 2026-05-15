#!/usr/bin/env bash
# Print the short hostname IFF this tmux session is being attached
# to via SSH. Otherwise print nothing.
#
# Used by the Primer themes' status-left so the hostname segment only
# appears on remote machines (locally, the shell prompt already shows
# host info). Bound via #(...) in ~/.config/tmux/themes/_segmented.conf
# and _flat.conf.
#
# Detection method: walk every attached tmux client's parent process
# chain looking for an `sshd` ancestor. tmux's status-line #(...) calls
# run in the SERVER's environment, which doesn't reflect per-client SSH
# state, so process-tree walking is the only reliable signal here.

set -uo pipefail

is_any_client_ssh() {
  local cpid pid name
  for cpid in $(tmux list-clients -F '#{client_pid}' 2>/dev/null); do
    pid="$cpid"
    while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null; do
      name=$(ps -o comm= -p "$pid" 2>/dev/null | awk '{print $NF}')
      case "$name" in
        sshd|*/sshd) return 0 ;;
      esac
      pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    done
  done
  return 1
}

if is_any_client_ssh; then
  printf '%s' "$(hostname -s)"
fi
