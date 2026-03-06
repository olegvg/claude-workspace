#!/usr/bin/env fish

# ws - tmux workspace launcher with session type selector
# Usage:
#   ws [directory]            Interactive session picker
#   ws --docker [directory]   Skip menu, go straight to YOLO mode
#   ws --code [directory]     Skip menu, go straight to Code mode

set -l docker_mode false
set -l code_mode false
set -l target_dir ""

# Parse arguments
for arg in $argv
    switch $arg
        case -d --docker
            set docker_mode true
        case -c --code
            set code_mode true
        case '*'
            set target_dir $arg
    end
end

# Default to cwd if no directory specified
if test -z "$target_dir"
    set target_dir (pwd)
end

# Resolve to absolute path
set target_dir (realpath $target_dir)

# Verify we're inside tmux
if not set -q TMUX
    echo "Error: ws must be run inside a tmux session"
    exit 1
end

# Verify target directory exists
if not test -d $target_dir
    echo "Error: directory does not exist: $target_dir"
    exit 1
end

# Determine session type
set -l session_type ""

if test "$docker_mode" = true
    set session_type yolo
else if test "$code_mode" = true
    set session_type code
else
    # Interactive session picker
    echo ""
    set_color --bold white
    echo "  Select session type:"
    set_color normal
    echo ""
    set_color brblue
    echo "  1) Code   — Claude Code + Yazi"
    set_color bryellow
    echo "  2) YOLO   — Claude Code in Docker + Yazi"
    set_color brgreen
    echo "  3) Files  — Midnight Commander"
    set_color brwhite
    echo "  4) Shell  — Plain fish shell"
    set_color normal
    echo ""

    read -P "  > " -n 1 choice

    switch $choice
        case 1 c
            set session_type code
        case 2 y
            set session_type yolo
        case 3 m f
            set session_type files
        case 4 s
            set session_type shell
        case '*'
            echo "Cancelled."
            exit 0
    end
end

# Launch the selected session type
switch $session_type
    case code
        tmux rename-window "code"
        tmux split-window -v -p 20 -c $target_dir
        tmux select-pane -U
        tmux split-window -h -p 30 -c $target_dir
        tmux send-keys "cd $target_dir && claude" C-m
        tmux select-pane -L
        tmux send-keys "yazi $target_dir" C-m

    case yolo
        # Ensure docker image is built
        set -l script_dir (status dirname)
        set -l image_name "claude-yolo"

        if not docker image inspect $image_name &>/dev/null
            echo "Building $image_name Docker image..."
            docker build -t $image_name $script_dir
        end

        if not test -f ~/.claude/.credentials.json
            echo "Error: ~/.claude/.credentials.json not found. Run 'claude' to authenticate first."
            exit 1
        end

        set -l claude_bin (readlink -f ~/.local/bin/claude)
        set claude_cmd "docker run -it --rm -v \$HOME/.claude:/home/coder/.claude -v \$HOME/.claude.json:/home/coder/.claude.json -v $claude_bin:/usr/local/bin/claude:ro -v \"$target_dir\":/workspace $image_name"

        tmux rename-window "yolo"
        tmux split-window -v -p 20 -c $target_dir
        tmux select-pane -U
        tmux split-window -h -p 30 -c $target_dir
        tmux send-keys "$claude_cmd" C-m
        tmux select-pane -L
        tmux send-keys "yazi $target_dir" C-m

    case files
        tmux rename-window "files"
        tmux send-keys "mc $target_dir" C-m

    case shell
        tmux rename-window "shell"
        tmux send-keys "cd $target_dir" C-m
end
