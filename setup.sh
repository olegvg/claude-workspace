#!/usr/bin/env bash
set -euo pipefail

# ============================================
# CLI Setup — Debian-based VPS
# Installs: tmux, fish, yazi, mc, claude code
# Configures: tmux.conf, ws script
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/bin"

info()  { printf '\033[1;34m[INFO]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[OK]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$1"; }
err()   { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1"; exit 1; }

# ============================================
# 1. System packages
# ============================================
info "Updating package lists..."
sudo apt-get update -qq

info "Installing tmux, fish, mc..."
sudo apt-get install -y -qq tmux fish mc

# ============================================
# 2. Yazi (from GitHub releases)
# ============================================
if command -v yazi &>/dev/null; then
    ok "yazi already installed: $(yazi --version)"
else
    info "Installing yazi from GitHub releases..."
    YAZI_VERSION=$(curl -sS https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    YAZI_ARCHIVE="yazi-x86_64-unknown-linux-gnu.zip"
    YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${YAZI_ARCHIVE}"

    TMP_DIR=$(mktemp -d)
    curl -fsSL "$YAZI_URL" -o "$TMP_DIR/$YAZI_ARCHIVE"
    unzip -q "$TMP_DIR/$YAZI_ARCHIVE" -d "$TMP_DIR"
    sudo cp "$TMP_DIR"/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
    sudo chmod +x /usr/local/bin/yazi
    rm -rf "$TMP_DIR"
    ok "yazi installed: $(yazi --version)"
fi

# ============================================
# 3. Claude Code (native installer)
# ============================================
if command -v claude &>/dev/null; then
    ok "claude already installed: $(claude --version 2>/dev/null || echo 'installed')"
else
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    ok "Claude Code installed"
fi

# ============================================
# 4. Docker + YOLO image
# ============================================
if command -v docker &>/dev/null; then
    ok "docker already installed"
else
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker "$USER"
    ok "Docker installed (re-login for group to take effect)"
fi

if docker image inspect claude-yolo &>/dev/null 2>&1; then
    ok "claude-yolo image already built"
else
    info "Building claude-yolo Docker image..."
    docker build -t claude-yolo "$SCRIPT_DIR"
    ok "claude-yolo image built"
fi

# ============================================
# 5. Yazi Dracula theme
# ============================================
YAZI_FLAVOR_DIR="$HOME/.config/yazi/flavors/dracula.yazi"
if [ -d "$YAZI_FLAVOR_DIR" ]; then
    ok "yazi dracula theme already installed"
else
    info "Installing yazi Dracula theme..."
    mkdir -p "$HOME/.config/yazi/flavors"
    git clone https://github.com/dracula/yazi.git "$YAZI_FLAVOR_DIR"
    ok "yazi Dracula theme installed"
fi
ln -sf "$SCRIPT_DIR/yazi-theme.toml" "$HOME/.config/yazi/theme.toml"
ok "~/.config/yazi/theme.toml -> $SCRIPT_DIR/yazi-theme.toml"

# ============================================
# 6. tmux config
# ============================================
info "Linking tmux.conf..."
ln -sf "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
ok "~/.tmux.conf -> $SCRIPT_DIR/tmux.conf"

# ============================================
# 7. ws script
# ============================================
info "Setting up ws script..."
mkdir -p "$BIN_DIR"
ln -sf "$SCRIPT_DIR/ws.fish" "$BIN_DIR/ws"
chmod +x "$BIN_DIR/ws"
ok "~/bin/ws -> $SCRIPT_DIR/ws.fish"

# ============================================
# 8. Ensure ~/bin is in fish PATH
# ============================================
FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$(dirname "$FISH_CONFIG")"
if ! grep -q 'fish_add_path ~/bin' "$FISH_CONFIG" 2>/dev/null; then
    echo 'fish_add_path ~/bin' >> "$FISH_CONFIG"
    ok "Added ~/bin to fish PATH"
else
    ok "~/bin already in fish PATH"
fi

# ============================================
# Done
# ============================================
echo ""
ok "Setup complete!"
echo ""
echo "  Usage:"
echo "    1. Start tmux:          tmux"
echo "    2. Launch workspace:    ws ~/my-project"
echo "    3. Launch yolo mode:    ws --docker ~/my-project"
echo "    4. Switch panes:        C-a h / C-a l"
echo "    5. Window presets:      C-a w"
echo ""
echo "  Optional — set fish as default shell:"
echo "    chsh -s $(which fish)"
echo ""
