# shell aliases

# navigation & listing
if command -v eza &> /dev/null; then
  alias ls='eza'
  alias lsd='eza -D'
  alias ll='eza -l'
  alias lll='eza -la'
else
  alias ls='ls -G'
  alias lsd='ls -ld */'
  alias ll='ls -lh'
  alias lll='ls -lah'
fi

# ssh & remote
alias sshnull='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scpnull='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias rsyncnull='rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"'

# quick edit
alias editssh='$EDITOR ~/.ssh/config'
alias edithosts='$EDITOR /etc/hosts'
alias editalias='$EDITOR ~/.config/zsh/aliases.zsh'
alias editgit='$EDITOR ~/.gitconfig'

# terminal & multiplexer
alias t='tmux attach 2> /dev/null || tmux new-session'
alias guake='zellij attach guake'

# tool replacements
alias vi='$EDITOR'
alias vim='$EDITOR'
alias pip='pip3'
alias cat='bat'
alias ping='prettyping --nolegend'

# utilities
alias ap='ansible-playbook'
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

# linux
if [[ "$(uname)" == "Linux" ]]; then
  alias lports='ss -ltn'
  alias tports='ss -tn'
  alias uports='ss -un'
  alias gvfs='cd /run/user/1000/gvfs/'
  alias lock='xdg-screensaver lock'
fi

# macos
if [[ "$(uname)" == "Darwin" ]]; then
  alias lports='sudo lsof -iTCP -sTCP:LISTEN -nP'
  alias tports='sudo lsof -iTCP -nP'
  alias uports='sudo lsof -iUDP -nP'
fi

# work

