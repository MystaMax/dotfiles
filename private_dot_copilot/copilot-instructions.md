# Global Instructions

## Git Commit Message Rules

Adhere to the seven rules for Git commit messages:

1. Separate subject and body with a blank line.
2. Limit subject to 50 characters.
3. Capitalize the subject.
4. Do not end the subject with a period.
5. Use the imperative mood (e.g., "Add feature" not "Added feature").
6. Wrap body lines at 72 characters.
7. Use the body to explain _what_ and _why_, not _how_.
8. Use a bulleted list (`-`) in the body instead of prose paragraphs.

### Format

`[EMOJI] (scope): [CONCISE SUBJECT]`

### Emoji Map

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

## Coding Preferences

- Only comment code that is non-obvious or requires clarification.
- Prefer readability over cleverness.
- Follow the naming conventions of the language being used (e.g., `snake_case` in Python/Ruby, `camelCase` in JavaScript/TypeScript, `PascalCase` for types/classes).
- Keep functions small and focused on a single responsibility.
- Handle errors explicitly — avoid silently swallowing exceptions.
- Prefer early returns over deeply nested conditionals.
- Prefer `rg` (ripgrep) over `grep` for searching file contents.

## Language-Specific

### Python

- Use `uv` for package and environment management. Avoid `pip`.
- Use `ruff` for linting and formatting. Avoid `black`, `isort`, and `flake8`.

## Environment

- **OS:** macOS (primary), Linux
- **Shell:** zsh
- **Terminal:** Ghostty with Zellij
- **Editor:** Neovim (primary), VS Code
