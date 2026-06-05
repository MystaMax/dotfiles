---
name: git-commit
description: Write well-structured git commit messages following a specific emoji-scoped format. Use this skill whenever the user asks to commit changes, write a commit message, stage and commit, or review a diff for committing. Also trigger when the user says things like "commit this", "let's commit", "write a commit message for these changes", or asks to push changes that haven't been committed yet. If changes are staged or a diff is available, analyze them to generate the commit message automatically.
---

# Git Commit Message Skill

Generate git commit messages that follow a strict emoji-scoped format with conventional commit principles.

## Format

Every commit message subject line follows this pattern:

```
[EMOJI] (scope): [CONCISE SUBJECT]
```

**Example subjects:**
- `🐛 (zsh): Fix Homebrew completions missing from fpath`
- `📚 (repo): Add detailed README`
- `⚡ (copilot): Add Python tooling preferences`
- `🔧 (starship): Increase command timeout to 1s`
- `🔨 (terminal): Clean up Ghostty and Zellij configs`
- `➕ (copilot): Add global custom instructions`

## Emoji Map

Pick the emoji that best describes the *category* of the change:

| Category         | Emojis                                                        |
| :--------------- | :------------------------------------------------------------ |
| **Setup & Meta** | 🎉 Initial, 🔖 Version, 🗂 Metadata, 🔧 Config, 🚚 Move/Rename |
| **Development**  | ✨ Feature, ⚡ Update, 🎨 Structure, 🔨 Refactor, 🔥 Remove   |
| **Fixes**        | 🐛 Bugfix, 🚑 Critical, 🍎 macOS, 🐧 Linux, 🏁 Windows        |
| **Docs & Style** | 📚 Docs, 💡 Code Docs, 💄 Cosmetic, ✏️ Text, 👽 Translation   |
| **DevOps & CI**  | 🚀 Deploy, 💚 CI, 👷‍♂️ Build, 🐳 Docker, 📦 Package             |
| **Quality**      | 🚨 Tests, ✅ Add Test, ✔️ Pass Test, 🔒 Security, 👕 Lint     |
| **Dependencies** | ⬆️ Upgrade, ⬇️ Downgrade, ➕ Add, ➖ Remove                   |
| **Process**      | 🚧 WIP, 🔀 Merge, ⏪ Revert, 💥 Breaking, 👌 Review, 🦽 A11y  |

## The Seven Rules (plus one)

1. **Separate subject and body with a blank line.** Git tooling relies on this separation.
2. **Limit the subject to 50 characters.** The emoji and scope are part of this count. Be concise — if you can't fit it, the scope or wording needs tightening.
3. **Capitalize the subject.** The first word after the colon-space should be capitalized (e.g., `Fix`, not `fix`).
4. **Do not end the subject with a period.** It's a title, not a sentence.
5. **Use the imperative mood.** Write as if completing the sentence "If applied, this commit will..." — so "Add feature" not "Added feature" or "Adds feature".
6. **Wrap body lines at 72 characters.** This ensures readability in `git log` and terminal tools.
7. **Use the body to explain *what* and *why*, not *how*.** The diff shows the how. The body provides context that isn't obvious from the code.
8. **Use a bulleted list (`-`) in the body instead of prose paragraphs.** Keep it scannable.

## Workflow

When asked to commit changes:

1. **Check `git status`** to understand what's staged and what isn't.
2. **Read the diff** (`git diff --staged` or `git diff`) to understand the actual changes.
3. **Determine the scope** — this is usually the area of the codebase affected (e.g., `zsh`, `docker`, `api`, `auth`). Use short, lowercase labels.
4. **Pick the right emoji** based on the nature of the change, not the files touched. A bug fix in a config file is still 🐛, not 🔧.
5. **Write the subject** — concise, imperative, under 50 characters total.
6. **Write the body** (if the change warrants explanation) — bulleted list of what changed and why. Skip the body for trivial single-line changes.

## Examples

**Simple config change (no body needed):**
```
🔧 (starship): Increase command timeout to 1s
```

**Multi-file refactor (body explains what and why):**
```
🔨 (zsh): Reorganize shell config into ~/.config/zsh

- Move aliases to ~/.config/zsh/aliases.zsh
- Merge functions and zd into ~/.config/zsh/functions.zsh
- Update plugin paths to ~/.config/zsh/plugins/
- Source ~/.config/zsh/*.zsh via loop
- Remove standalone bin/zd and dot_functions
```

**Bug fix (body explains the cause):**
```
🐛 (zsh): Fix character duplication over SSH from Ghostty

Fall back to xterm-256color when xterm-ghostty terminfo
is missing on the remote system
```

**Security-sensitive change:**
```
🔒 (repo): Remove exposed hostname from git history

- Scrub ESB_TOOLS value from all commits via git-filter-repo
- Rewrite author emails to use noreply address
```

## Common Mistakes to Avoid

- **Don't use past tense.** "Fixed bug" → "Fix bug"
- **Don't be vague.** "Update config" → "Guard tool-dependent config with command checks"
- **Don't explain how in the body.** The diff shows the how — explain *why* the change was made.
- **Don't skip the scope.** Every commit should have a scope in parentheses.
- **Don't use prose paragraphs in the body.** Use bulleted lists with `-`.
