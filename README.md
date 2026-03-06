# cli-setup

Terminal workspace for Claude Code on a Debian-based VPS. Splits tmux into a VSCode-like layout with Claude Code and Yazi file browser side by side.

## What's included

| File | Purpose |
|------|---------|
| `setup.sh` | Installs dependencies and links configs |
| `tmux.conf` | tmux config — C-a prefix, true-color, vi keys, mouse, status bar |
| `ws.fish` | Workspace launcher: Yazi + Claude Code + Shell pane |
| `yazi.toml` | Yazi config (panel ratios) |
| `yazi-theme.toml` | Yazi theme config (Dracula flavor) |
| `Dockerfile` | Debian-based container for Claude Code yolo mode |

## Install

```bash
git clone <your-repo> ~/cli-setup
cd ~/cli-setup
./setup.sh
```

Installs: tmux, fish, yazi, mc, claude code. Symlinks configs to the right places.

Optionally set fish as your default shell:

```bash
chsh -s $(which fish)
```

## Usage

Start tmux, then launch the workspace:

```bash
tmux
ws ~/my-project           # Claude Code + Yazi
ws                        # use current directory
ws --docker ~/my-project  # yolo mode in Docker + Yazi
ws -d                     # yolo mode, current directory
```

This gives you:

```
┌──────────────┬───────────┐
│   Yazi (70%) │Claude(30%)│
├──────────────┴───────────┤
│        Shell (20%)       │
└──────────────────────────┘
```

Press `C-a w` to open the window preset menu:

```
┌──────────────────────────┐
│       New Window         │
├──────────────────────────┤
│ c  Code  (Claude + Yazi) │
│ y  YOLO  (Docker + Yazi) │
│ m  Files (MC)            │
│ s  Shell                 │
└──────────────────────────┘
```

- **Code** — Yazi (70%) + Claude Code (30%) + Shell pane
- **YOLO** — Yazi + Claude Code in Docker (`--dangerously-skip-permissions`) + Shell pane
- **Files** — Full-screen Midnight Commander
- **Shell** — Plain shell

## YOLO mode (Docker)

Runs Claude Code inside a Docker container with `--dangerously-skip-permissions` — full autonomous mode. Your project directory is mounted at `/workspace` inside the container.

Build the image first:

```bash
docker build -t claude-yolo ~/cli-setup
```

Set your API key:

```bash
set -gx ANTHROPIC_API_KEY sk-ant-...
```

Then use `ws --docker` or press `y` in the `C-a w` menu.

## Keybindings

### Panes (within a window)

| Key | Action |
|-----|--------|
| `C-a h` | Focus left pane |
| `C-a l` | Focus right pane |
| `C-a j` | Focus pane below |
| `C-a k` | Focus pane above |
| `C-a H/J/K/L` | Resize pane |
| Mouse click | Focus pane |

### Windows (tabs)

| Key | Action |
|-----|--------|
| `C-a w` | **New window preset menu** (Code / YOLO / MC / Shell) |
| `C-a c` | New blank window |
| `C-a Space` | Next window |
| `C-a C-a` | Toggle last window |
| `C-a 1-9` | Jump to window by number |

### Splits

| Key | Action |
|-----|--------|
| `C-a \|` | Split vertically |
| `C-a -` | Split horizontally |

### Other

| Key | Action |
|-----|--------|
| `C-a r` | Reload tmux config |
| `C-a d` | Detach session |
| `C-a [` | Enter copy mode (vi keys) |

## Requirements

- Debian-based Linux (Ubuntu, Debian)
- x86_64 architecture
- sudo access
- Docker (for yolo mode only)
