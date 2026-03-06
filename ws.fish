#!/usr/bin/env fish

# ws - split current tmux pane into Claude Code (70%) + Yazi (30%)
# Usage:
#   ws [directory]            Claude Code + Yazi
#   ws --docker [directory]   Claude Code (yolo mode in Docker) + Yazi

set -l docker_mode false
set -l target_dir ""

# Parse arguments
for arg in $argv
    switch $arg
        case -d --docker
            set docker_mode true
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

# Build the claude launch command
if test "$docker_mode" = true
    # Ensure docker image is built
    set -l script_dir (status dirname)
    set -l image_name "claude-yolo"

    if not docker image inspect $image_name &>/dev/null
        echo "Building $image_name Docker image..."
        docker build -t $image_name $script_dir
    end

    set claude_cmd "docker run -it --rm \
        -e ANTHROPIC_API_KEY=\$ANTHROPIC_API_KEY \
        -v $target_dir:/workspace \
        $image_name"

    tmux rename-window "yolo"
else
    set claude_cmd "cd $target_dir && claude"
    tmux rename-window "code"
end

# Split right pane (30%) for yazi
tmux split-window -h -p 30 -c $target_dir "yazi $target_dir"

# Left pane (auto 70%) runs claude
tmux select-pane -L
tmux send-keys "$claude_cmd" C-m
