#!/bin/bash

# Function to detect operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    else
        echo "unknown"
    fi
}

install_base_packages() {
    echo "🔄 Updating package list..."
    apt-get update -qq
    
    echo "📦 Installing basic dependencies..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        fzf \
        wget \
        gnupg \
        apt-transport-https \
        lsb-release \
        build-essential \
        pkg-config
}

install_rust() {
    echo "🦀 Installing Rust and Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path
    source "$HOME/.cargo/env"
}

install_cli_tools() {
    echo "🛠️ Installing CLI tools (just, aichat)..."
    cargo install just
    cargo install aichat
}

cleanup() {
    echo "🧹 Cleaning up..."
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

install_base_packages
install_rust
install_cli_tools

echo "🔄 Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

echo "📍 Installing zoxide..."
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

cleanup
