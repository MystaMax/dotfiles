# Global Instructions

## Git Commit Messages

Use the `git-commit` skill for commit message formatting and conventions.

## Coding Preferences

- Only comment code that is non-obvious or requires clarification.
- Prefer readability over cleverness.
- Follow the naming conventions of the language being used (e.g., `snake_case` in Python/Ruby, `camelCase` in JavaScript/TypeScript, `PascalCase` for types/classes).
- Keep functions small and focused on a single responsibility.
- Handle errors explicitly — avoid silently swallowing exceptions.
- Prefer early returns over deeply nested conditionals.
- Prefer `rg` (ripgrep) over `grep` for searching file contents.

## Writing Style & Formatting

- Never use em dashes (—) in writing. Instead, use other punctuation like periods, commas, colons, semicolons, or parentheses as appropriate. For example: use a period to end a sentence, a colon to introduce a list, a semicolon to join related clauses, or parentheses for asides.

## Language-Specific

### Python

- Use `uv` for package and environment management. Avoid `pip`.
- Use `ruff` for linting and formatting. Avoid `black`, `isort`, and `flake8`.

## Environment

- **OS:** macOS (primary), Linux
- **Shell:** zsh
- **Terminal:** Ghostty with Zellij
- **Editor:** Neovim (primary), VS Code
- **Dev Containers:** Preferred for new projects when practical. Suggest devcontainer setup for new projects, but don't force it on existing ones. Always include the `yzhang.markdown-all-in-one` VS Code extension.
