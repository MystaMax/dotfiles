#!/usr/bin/env bash

# Shell functions

function cheat() {
  curl https://cheat.sh/"${1}"
}

function gi() {
  curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/"$@"
}

# color pagination with jq
# https://github.com/stedolan/jq/issues/764#issuecomment-379688272

jql() {
  # -F tell less exit if output content can be displayed on one screen
  jq -C "$@" | less -FR
}

# Navigate to ~/customers
# The ARGV variable is need because you cannot access positional arguments
# inside a bash function without the ARGV array
args=("$@")

function customers {
  echo "${args[1]}"
  cd ~/customers/"${args[1]}"
}

# Print $PATH line-by-line
function echopath {
  echo "${PATH}" | tr : '\n'
}

zdt() {
  local target_directory="zd$1"
  local found_directory

  #found_directory=$(find ~/customers -type d -name "$target_directory" -print -quit)
  found_directory=$(fd -t d -g "*$target_directory" ~/customers)

  if [[ -n "$found_directory" ]]; then
    cd "$found_directory" || exit
    echo "Changed to directory: $found_directory"
  else
    echo "Directory '$target_directory' not found."
  fi
}

# Read a Slack thread via gh and either copy or print
slackread() {
  local mode="copy"
  local limit=400

  # Parse options
  while [ "$#" -gt 0 ]; do
    case "$1" in
    -p | --print)
      mode="print"
      shift
      ;;
    -c | --copy)
      mode="copy"
      shift
      ;;
    -l | --limit)
      limit="$2"
      shift 2
      ;;
    -h | --help)
      echo "Usage: slackread [OPTIONS] <SLACK-THREAD-URL>"
      echo
      echo "Options:"
      echo "  -c, --copy    Copy thread to clipboard (default)"
      echo "  -p, --print   Print thread to terminal"
      echo "  -l, --limit N Set message limit (default: 400)"
      return 0
      ;;
    *)
      break
      ;;
    esac
  done

  if [ "$#" -lt 1 ]; then
    echo "Usage: slackread [OPTIONS] <SLACK-THREAD-URL>" >&2
    return 1
  fi

  local url="$1"

  if [ "$mode" = "copy" ]; then
    gh slack read -l "$limit" "$url" | pbcopy
  else
    gh slack read -l "$limit" "$url"
  fi
}

# Create and jump into a GitHub support ticket folder
# Usage: zd [customer] [ticket]
# Example: zd ibm 123456
function zd() {
    local customers_dir="$HOME/customers"
    local customer_arg="$1"
    local ticket_arg="$2"
    local customer ticket base_dir

    function prompt_for_inputs {
        if [ -z "$customer_arg" ]; then
            read -rp "Enter customer name: " customer_arg
        fi
        if [ -z "$ticket_arg" ]; then
            read -rp "Enter ticket number: " ticket_arg
        fi
    }

    function sanitize_inputs {
        customer=$(echo "$customer_arg" | awk '{$1=$1};1' | tr '[:upper:]' '[:lower:]')
        ticket=$(echo "$ticket_arg" | awk '{$1=$1};1')
    }

    function check_ticket_number {
        if [[ ! "$ticket" =~ ^[0-9]+$ ]]; then
            echo "❌ Ticket number must be numeric." >&2
            return 1
        fi
    }

    function create_dirs {
        base_dir="$customers_dir/$customer/tickets/zd$ticket"
        mkdir -p "$base_dir"
    }

    function change_to_dir {
        cd "$base_dir" || {
            echo "Failed to cd into $base_dir" >&2
            return 1
        }
        echo "📁 Now in: $(pwd)"
    }

    prompt_for_inputs
    sanitize_inputs
    check_ticket_number || return 1
    create_dirs
    change_to_dir
}

# Launch Copilot CLI in YOLO mode. When run anywhere under ~/customers,
# load shared instructions from ~/customers/AGENTS.md via
# COPILOT_CUSTOM_INSTRUCTIONS_DIRS so customer subfolders inherit the rules.
cpy() {
    local customers_dir="$HOME/customers"
    local name_args=()
    local force_new=false
    local check_dir="$PWD"

    # Parse cpy-specific flags before passing rest to copilot
    local cpy_args=()
    for arg in "$@"; do
        if [[ "$arg" == "-n" || "$arg" == "--new" ]]; then
            force_new=true
        else
            cpy_args+=("$arg")
        fi
    done

    # Walk up to find a ticket root (~/customers/*/tickets/zd<id>)
    while [[ "$check_dir" == "$customers_dir"/* ]]; do
        if [[ "$check_dir" =~ "$HOME/customers/[^/]+/tickets/(zd[0-9]+)$" ]]; then
            local session_name="${match[1]}"
            if ! $force_new; then
                local existing
                existing=$(rg -l "^name: ${session_name}$" \
                    ~/.copilot/session-state/*/workspace.yaml 2>/dev/null | head -1)
                if [[ -n "$existing" ]]; then
                    name_args=(--resume="$session_name")
                else
                    name_args=(--name "$session_name")
                fi
            fi
            break
        fi
        check_dir="${check_dir:h}"
    done

    if [[ "$PWD" == "$customers_dir" || "$PWD" == "$customers_dir"/* ]]; then
        COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$customers_dir" copilot --yolo "${name_args[@]}" "${cpy_args[@]}"
    else
        copilot --yolo "${name_args[@]}" "${cpy_args[@]}"
    fi
}

# zellij-health: list every running Zellij server with CPU%, age, and PID,
# sorted by CPU descending. Anything sustained above 50% gets a warning
# marker — likely the session-manager plugin FD leak kicking in
# (see zellij-org/zellij#5056). Long-lived servers (multi-day uptime)
# are the usual suspects.
#
# Use when fans spin up or the machine feels sluggish. Kill any flagged
# server with `kill -9 <pid>`. Sessions are preserved by serialization
# and can be resurrected with `zellij attach <name>`.
#
# Added 2026-05-14 during a Copilot CLI troubleshooting session that
# uncovered two Zellij servers consuming 460%+ CPU combined after running
# for 7-9 days each.
zellij-health() {
    if ! pgrep -x zellij >/dev/null 2>&1; then
        echo "No Zellij servers running."
        return 0
    fi

    printf "SESSION              CPU%%      AGE             PID\n"
    ps -axo pid,pcpu,etime,command | awk '
        /[z]ellij --server/ {
            session = $NF
            sub(/.*\//, "", session)
            cpu = $2 + 0
            warn = (cpu > 50) ? " ⚠️ " : ""
            # Prepend zero-padded CPU as sort key, strip with cut after sort
            printf "%015.2f\t%-20s %6.1f%%  %-15s  %s%s\n", \
                cpu, session, cpu, $3, $1, warn
        }' | sort -rn | cut -f2-
}
