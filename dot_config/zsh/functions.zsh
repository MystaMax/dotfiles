#!/usr/bin/env bash

# Shell functions

# Source work/private overrides (hostnames, internal URLs, etc).
# This file is NOT tracked by chezmoi, so values here never land in the
# public dotfiles repo. Add private values (and any functions that
# reference internal tooling) to ~/.config/zsh/private.zsh. The loop
# in ~/.zshrc sources every *.zsh file in ~/.config/zsh/ automatically.

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
#
# Ticket-dir behavior (~/customers/<co>/tickets/zd<id>):
#   - Resumes the most-recently-used session for the ticket by matching cwd
#     (not name), so renaming the session in-CLI doesn't break resume.
#   - Caches the resolved session UUID at
#     ~/.copilot/session-state/.cpy-cache/<co>__zd<id> for sub-millisecond
#     resume on subsequent launches.
#   - Flags (intercepted by cpy, never forwarded to copilot):
#       -n / --new   force a fresh session (clears cache)
#       -P / --pick  interactively pick among multiple sessions for this ticket
cpy() {
    local customers_dir="$HOME/customers"
    local state_dir="$HOME/.copilot/session-state"
    local cache_dir="$state_dir/.cpy-cache"
    local name_args=()
    local force_new=false
    local pick=false
    local check_dir="$PWD"

    # Parse cpy-specific flags before passing rest to copilot
    local cpy_args=()
    local arg
    for arg in "$@"; do
        case "$arg" in
            -n|--new)  force_new=true ;;
            -P|--pick) pick=true ;;
            *)         cpy_args+=("$arg") ;;
        esac
    done

    # Walk up to find a ticket root (~/customers/<co>/tickets/zd<id>)
    local ticket_root="" company="" session_name=""
    while [[ "$check_dir" == "$customers_dir"/* ]]; do
        if [[ "$check_dir" =~ "$HOME/customers/([^/]+)/tickets/(zd[0-9]+)$" ]]; then
            company="${match[1]}"
            session_name="${match[2]}"
            ticket_root="$check_dir"
            break
        fi
        check_dir="${check_dir:h}"
    done

    if [[ -n "$ticket_root" ]]; then
        local cache_file="$cache_dir/${company}__${session_name}"
        local resume_uuid=""

        if ! $force_new; then
            # Tier 1: cache hot path (skip when -P, user wants to choose)
            if ! $pick && [[ -r "$cache_file" ]]; then
                local cached_uuid
                cached_uuid="$(<$cache_file)"
                if [[ -n "$cached_uuid" && -d "$state_dir/$cached_uuid" ]]; then
                    if head -n 20 "$state_dir/$cached_uuid/workspace.yaml" 2>/dev/null \
                        | grep -qxF "cwd: $ticket_root"; then
                        resume_uuid="$cached_uuid"
                    fi
                fi
            fi

            # Tier 2: cold scan
            if [[ -z "$resume_uuid" ]]; then
                local matches_str
                matches_str="$(rg -l "^cwd: ${ticket_root}$" "$state_dir" \
                    --glob 'workspace.yaml' --max-depth 2 2>/dev/null)"
                local -a matches
                [[ -n "$matches_str" ]] && matches=("${(@f)matches_str}")

                if (( ${#matches} > 0 )); then
                    if $pick && (( ${#matches} > 1 )); then
                        resume_uuid="$(_cpy_pick_session "${matches[@]}")"
                    else
                        # Most recently modified workspace.yaml wins
                        local f mtime newest_file="" newest_mtime=0
                        for f in "${matches[@]}"; do
                            mtime=$(stat -f "%m" "$f" 2>/dev/null) || continue
                            if (( mtime > newest_mtime )); then
                                newest_mtime=$mtime
                                newest_file="$f"
                            fi
                        done
                        [[ -n "$newest_file" ]] && resume_uuid="${newest_file:h:t}"
                    fi
                fi
            fi
        fi

        if [[ -n "$resume_uuid" ]]; then
            name_args=(--session-id="$resume_uuid")
            mkdir -p "$cache_dir"
            print -r -- "$resume_uuid" > "$cache_file"
        else
            # Fresh session: let Copilot generate the UUID. Drop any stale cache
            # so the next cpy launch picks up the new session via cold scan.
            name_args=(--name "$session_name")
            [[ -f "$cache_file" ]] && rm -f "$cache_file"
        fi
    fi

    if [[ "$PWD" == "$customers_dir" || "$PWD" == "$customers_dir"/* ]]; then
        COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$customers_dir" copilot --yolo "${name_args[@]}" "${cpy_args[@]}"
    else
        copilot --yolo "${name_args[@]}" "${cpy_args[@]}"
    fi
}

# Interactive picker for cpy. Takes workspace.yaml paths, prints chosen UUID to
# stdout. Uses fzf if available, otherwise a numbered prompt.
_cpy_pick_session() {
    local files=("$@")
    local -a lines
    local f uuid name updated mtime
    for f in "${files[@]}"; do
        uuid="${f:h:t}"
        mtime=$(stat -f "%m" "$f" 2>/dev/null) || continue
        updated=$(date -r "$mtime" "+%Y-%m-%d %H:%M" 2>/dev/null)
        name=$(awk '/^name: /{sub(/^name: /,""); print; exit}' "$f" 2>/dev/null)
        [[ -z "$name" ]] && name="(unnamed)"
        # Format: mtime|display|uuid (mtime first for numeric sort)
        lines+=("${mtime}|${updated}  ${name}  ${uuid:0:8}|${uuid}")
    done

    local sorted
    sorted=$(printf '%s\n' "${lines[@]}" | sort -t'|' -k1,1 -rn)

    local choice_uuid=""
    if command -v fzf >/dev/null 2>&1; then
        local picked
        picked=$(printf '%s\n' "$sorted" | awk -F'|' '{print $2"\t"$3}' \
            | fzf --with-nth=1 --delimiter=$'\t' \
                  --prompt="Resume session > " \
                  --height=40% --reverse)
        [[ -n "$picked" ]] && choice_uuid="${picked##*$'\t'}"
    else
        local -a display_lines uuids
        local line disp uu
        while IFS= read -r line; do
            disp="${${line#*|}%|*}"
            uu="${line##*|}"
            display_lines+=("$disp")
            uuids+=("$uu")
        done <<< "$sorted"

        local i=1 sel
        for disp in "${display_lines[@]}"; do
            print -u2 -- "$i) $disp"
            ((i++))
        done
        print -nu2 -- "Select [1-${#display_lines}]: "
        read sel
        if [[ "$sel" =~ ^[0-9]+$ ]] && (( sel >= 1 && sel <= ${#display_lines} )); then
            choice_uuid="${uuids[$sel]}"
        fi
    fi
    print -r -- "$choice_uuid"
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
