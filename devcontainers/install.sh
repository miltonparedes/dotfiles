#!/bin/bash

set -e

echo "🚀 Starting development environment setup..."

# Check for sudo privileges
if ! command -v sudo &> /dev/null; then
    echo "❌ 'sudo' command is required but not installed."
    exit 1
fi

# Check for OPENAI_API_KEY
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  No OPENAI_API_KEY environment variable found"
    echo "ℹ️  To use aichat with OpenAI, run the installation like this:"
    echo "    export OPENAI_API_KEY=your-api-key-here"
    echo "    curl -sSL https://raw.githubusercontent.com/miltonparedes/dotfiles/main/devcontainers/install.sh | bash"
    echo ""
    read -p "Do you want to continue without setting OPENAI_API_KEY? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
REPO_URL="https://raw.githubusercontent.com/miltonparedes/dotfiles/main"

# Function to download a file with verification
download_file() {
    local url="$1"
    local output="$2"
    local filename=$(basename "$output")
    
    echo "📥 Downloading ${filename}..."
    if ! curl -sSLf "$url" -o "$output"; then
        echo "❌ Failed to download ${filename}"
        echo "URL: ${url}"
        echo "HTTP Status: $(curl -s -o /dev/null -w "%{http_code}" "$url")"
        return 1
    fi
    
    if [ ! -s "$output" ]; then
        echo "❌ Downloaded file ${filename} is empty"
        return 1
    fi
}

# Download necessary files
echo "📥 Downloading configuration files..."
download_file "${REPO_URL}/devcontainers/packages.sh" "${TEMP_DIR}/packages.sh" || exit 1
download_file "${REPO_URL}/devcontainers/aliases" "${TEMP_DIR}/aliases" || exit 1
download_file "${REPO_URL}/lazygit/config.yml" "${TEMP_DIR}/lazygit_config.yml" || exit 1
download_file "${REPO_URL}/aichat/config.yaml" "${TEMP_DIR}/aichat_config.yaml" || exit 1

# Make packages.sh executable
chmod +x "${TEMP_DIR}/packages.sh"

# Source the packages script
source "${TEMP_DIR}/packages.sh"

echo "👤 Configuring environment..."

# Setup shell configurations
for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        if [ -f "${TEMP_DIR}/aliases" ]; then
            cat "${TEMP_DIR}/aliases" >> "$SHELL_RC" || {
                echo "❌ Failed to append aliases to ${SHELL_RC}"
                continue
            }
            echo 'source "$HOME/.cargo/env"' >> "$SHELL_RC" || {
                echo "❌ Failed to append cargo env to ${SHELL_RC}"
                continue
            }
            echo "✅ Successfully configured $(basename ${SHELL_RC})"
        else
            echo "❌ Aliases file not found at ${TEMP_DIR}/aliases"
            echo "⚠️ Skipping aliases setup for $(basename ${SHELL_RC})"
        fi
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
