# cli-setup

Terminal workspace for Claude Code on Debian-based VPS servers. Provides a VSCode-like tmux layout with split panes and window presets.

## Project structure

```
setup.sh       — Install script (apt packages, yazi, claude, docker, configs)
tmux.conf      — tmux config (C-a prefix, true-color, vi keys, window presets)
ws.fish        — Workspace launcher: Yazi + Claude Code + Shell pane
yazi.toml      — Yazi config (panel ratios)
yazi-theme.toml — Yazi theme config (Dracula)
Dockerfile     — Container for Claude Code yolo mode (--dangerously-skip-permissions)
README.md      — User-facing documentation
```

## Key decisions

- **Shell:** fish. All scripts use `#!/usr/bin/env fish`.
- **tmux prefix:** `C-a` (GNU Screen style), not the default `C-b`.
- **Yazi install:** GitHub releases binary (not in Debian repos).
- **Claude Code install:** Native installer (`curl -fsSL https://claude.ai/install.sh | bash`), not npm.
- **Docker yolo mode:** Uses `node:20-slim` base image, runs as non-root `coder` user, mounts project at `/workspace`.
- **Config management:** `setup.sh` symlinks files from this repo to their target locations (`~/.tmux.conf`, `~/bin/ws`). Edit files here, not in `~`.

## Conventions

- Keep configs minimal — no unnecessary plugins or frameworks.
- tmux window presets are defined in `tmux.conf` under the `display-menu` binding (`C-a w`).
- The `ws.fish` script is the CLI entrypoint. It handles both normal and docker modes via `--docker`/`-d` flag.
- Target platform is Debian-based x86_64 Linux. macOS is not a target.

## Git

- Never add `Co-Authored-By` lines to commits.

## Testing changes

- tmux config: `tmux source-file tmux.conf` inside a tmux session, or `tmux -f tmux.conf start-server` to validate parsing.
- ws script: Run outside tmux to verify the guard message. Run inside tmux to test the split.
- Dockerfile: `docker build -t claude-yolo .` then `docker run -it --rm claude-yolo --help`.
- setup.sh: Test on a fresh Debian container or VM.
