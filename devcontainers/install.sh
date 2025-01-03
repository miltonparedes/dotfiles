#!/bin/bash

set -e

echo "🚀 Starting development environment setup..."

# Check for OPENAI_API_KEY
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  No OPENAI_API_KEY environment variable found"
    echo "ℹ️  To use aichat with OpenAI, run the installation like this:"
    echo "    export OPENAI_API_KEY=your-api-key-here"
    echo "    curl -sSL https://raw.githubusercontent.com/milton/dotfiles/main/devcontainers/install.sh | bash"
    echo ""
    read -p "Do you want to continue without setting OPENAI_API_KEY? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
REPO_URL="https://raw.githubusercontent.com/milton/dotfiles/main"

# Download necessary files
echo "📥 Downloading configuration files..."
curl -sSL "${REPO_URL}/devcontainers/packages.sh" -o "${TEMP_DIR}/packages.sh"
curl -sSL "${REPO_URL}/devcontainers/aliases" -o "${TEMP_DIR}/aliases"
curl -sSL "${REPO_URL}/lazygit/config.yml" -o "${TEMP_DIR}/lazygit_config.yml"
curl -sSL "${REPO_URL}/aichat/config.yaml" -o "${TEMP_DIR}/aichat_config.yaml"

# Source the packages script
source "${TEMP_DIR}/packages.sh"

echo "👤 Configuring environment..."

# Setup shell configurations
for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        cat "${TEMP_DIR}/aliases" >> "$SHELL_RC"
        echo 'source "$HOME/.cargo/env"' >> "$SHELL_RC"
        
        SHELL_NAME=$(basename "$SHELL")
        echo "eval \"\$(zoxide init $SHELL_NAME)\"" >> "$SHELL_RC"
    fi
done

# Setup lazygit configuration
echo "⚙️ Setting up lazygit configuration..."
LAZYGIT_CONFIG_DIR="$HOME/.config/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR"
cp "${TEMP_DIR}/lazygit_config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml"

# Setup aichat configuration
echo "⚙️ Setting up aichat configuration..."
AICHAT_CONFIG_DIR="$HOME/.config/aichat"
mkdir -p "$AICHAT_CONFIG_DIR"
cp "${TEMP_DIR}/aichat_config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml"

# Handle OpenAI API key
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "🔑 Setting up aichat OpenAI API key..."
    sed -i.bak "s/OPENAI_API_KEY_PLACEHOLDER/$OPENAI_API_KEY/" "${AICHAT_CONFIG_DIR}/config.yaml" && rm "${AICHAT_CONFIG_DIR}/config.yaml.bak"
else
    echo "ℹ️ No OPENAI_API_KEY found. To set it later, run:"
    echo 'sed -i.bak "s/OPENAI_API_KEY_PLACEHOLDER/<your-api-key-here>/" $HOME/.config/aichat/config.yaml'
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Setup completed!"
