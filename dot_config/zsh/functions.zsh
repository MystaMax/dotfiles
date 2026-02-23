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
