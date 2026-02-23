# Dotfiles

My personal configuration files, managed with [chezmoi](https://www.chezmoi.io/).

These dotfiles are designed for **macOS** (with some Linux support where noted) and cover shell configuration, terminal emulators, multiplexers, editors, and system utilities.

## What's Included

### Shell (Zsh)

| File | Target | Description |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | Main shell config — history, keybindings, completions, plugin loading, PATH, and environment variables |
| `dot_zprofile` | `~/.zprofile` | Login shell setup — Homebrew and OrbStack initialization |
| `dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | Shell aliases — navigation (`eza`), SSH helpers, quick-edit shortcuts, tool replacements (`bat`, `prettyping`), and platform-specific port listing |
| `dot_config/zsh/functions.zsh` | `~/.config/zsh/functions.zsh` | Shell functions — `cheat` (cheat.sh lookup), `gi` (gitignore generator), `jql` (colored jq pager), `zd`/`zdt` (support ticket directory management), `slackread` (Slack thread reader via `gh`) |

**Zsh plugins** (installed separately via automation, sourced from `~/.config/zsh/plugins/`):

- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)
- [prezto completion styles](https://github.com/sorin-ionescu/prezto)

### Git

| File | Target | Description |
|---|---|---|
| `private_dot_gitconfig.tmpl` | `~/.gitconfig` | Git config (chezmoi template) — uses 1Password SSH signing for commit signatures, VS Code as diff tool, LFS support |

This is a chezmoi **template** — `name`, `email`, and `signingkey` are populated from `chezmoi init` data rather than being hardcoded.

### Terminal Emulators

| File | Target | Description |
|---|---|---|
| `dot_config/ghostty/config` | `~/.config/ghostty/config` | [Ghostty](https://ghostty.org/) — block cursor, UbuntuMono Nerd Font, copy-on-select, custom keybindings |
| `dot_config/ghostty/themes/mysta` | `~/.config/ghostty/themes/mysta` | Custom Ghostty color theme — dark background with modified ANSI palette |

### Terminal Multiplexers

| File | Target | Description |
|---|---|---|
| `dot_config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | [tmux](https://github.com/tmux/tmux) — 256 color, custom prefix, vim-style pane navigation, mouse support |
| `dot_config/zellij/config.kdl` | `~/.config/zellij/config.kdl` | [Zellij](https://zellij.dev/) — full custom keybinding configuration with clear-defaults |

### Editors

| File | Target | Description |
|---|---|---|
| `dot_config/zed/private_settings.json` | `~/.config/zed/settings.json` | [Zed](https://zed.dev/) editor settings |

### System Monitors

| File | Target | Description |
|---|---|---|
| `dot_config/btop/btop.conf` | `~/.config/btop/btop.conf` | [btop](https://github.com/aristocratos/btop) system monitor configuration |
| `dot_config/private_htop/private_htoprc` | `~/.config/htop/htoprc` | [htop](https://htop.dev/) process viewer configuration |

### Input Remapping

| File | Target | Description |
|---|---|---|
| `dot_config/private_karabiner/private_karabiner.json` | `~/.config/karabiner/karabiner.json` | [Karabiner-Elements](https://karabiner-elements.pqrs.org/) — keyboard customization for macOS |

### Other Shells

| File | Target | Description |
|---|---|---|
| `dot_config/private_fish/config.fish` | `~/.config/fish/config.fish` | Minimal [Fish](https://fishshell.com/) shell config with Starship prompt |

### Prompt

| File | Target | Description |
|---|---|---|
| `dot_config/starship/starship.toml` | `~/.config/starship/starship.toml` | [Starship](https://starship.rs/) cross-shell prompt — shows hostname, username, Python version |

### VS Code

| File | Target | Description |
|---|---|---|
| `private_dot_local/private_share/vscode/github-md-to-pdf.css` | `~/.local/share/vscode/github-md-to-pdf.css` | GitHub-styled CSS for Markdown-to-PDF exports |

## How It Works

[Chezmoi](https://www.chezmoi.io/) maps files in this repo to their home directory targets using naming conventions:

| Prefix | Meaning |
|---|---|
| `dot_` | Replaced with `.` (e.g., `dot_zshrc` → `~/.zshrc`) |
| `private_` | File permissions set to `0600` (owner-only) |
| `.tmpl` | Processed as a Go template with chezmoi data |
| `dot_config/` | Maps to `~/.config/` |

### Setup on a New Machine

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply MystaMax
```

You'll be prompted for template values (name, email, signing key) on first run.

### Day-to-Day Usage

There are two workflows for editing managed files:

**Edit the actual file, then sync to chezmoi:**

```bash
# 1. Edit the file however you normally would
vim ~/.zshrc

# 2. Pull changes into chezmoi source
chezmoi add ~/.zshrc

# 3. Commit and push
cd ~/.local/share/chezmoi && git add -A && git commit -m "your message" && git push
```

**Edit through chezmoi directly:**

```bash
# Opens the chezmoi source copy in $EDITOR, applies on save
chezmoi edit ~/.zshrc

# Then commit and push
cd ~/.local/share/chezmoi && git add -A && git commit -m "your message" && git push
```

The first approach feels more natural — just edit your files as usual and run `chezmoi add` when you're happy. The second skips the `add` step since you're editing the source directly.

**Other useful commands:**

```bash
# Pull latest changes from remote and apply to home directory
chezmoi update

# Add a new file to chezmoi management
chezmoi add ~/.config/some/new-config

# See what chezmoi would change before applying
chezmoi diff

# Apply all pending changes from source to home directory
chezmoi apply
```

## Related

System-level setup (Homebrew packages, macOS defaults, app installation, Zsh plugin installation) is handled by a separate Ansible playbook — these dotfiles only cover configuration files.
