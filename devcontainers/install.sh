#!/bin/bash

set -e

echo "🚀 Starting development environment setup..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ -f "${SCRIPT_DIR}/packages.sh" ]; then
    source "${SCRIPT_DIR}/packages.sh"
elif [ -f "./devcontainers/packages.sh" ]; then
    source "./devcontainers/packages.sh"
else
    echo "❌ Cannot find packages.sh"
    exit 1
fi

echo "👤 Configuring environment..."

for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        if [ -f "${SCRIPT_DIR}/aliases" ]; then
            cat "${SCRIPT_DIR}/aliases" >> "$SHELL_RC"
        elif [ -f "./devcontainers/aliases" ]; then
            cat "./devcontainers/aliases" >> "$SHELL_RC"
        fi

        echo 'source "$HOME/.cargo/env"' >> "$SHELL_RC"

        SHELL_NAME=$(basename "$SHELL")
        echo "eval \"\$(zoxide init $SHELL_NAME)\"" >> "$SHELL_RC"
    fi
done

echo "⚙️ Setting up lazygit configuration..."
LAZYGIT_CONFIG_DIR="$HOME/.config/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR"

if [ -f "${PROJECT_ROOT}/lazygit/config.yml" ]; then
    cp "${PROJECT_ROOT}/lazygit/config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml"
elif [ -f "./lazygit/config.yml" ]; then
    cp "./lazygit/config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml"
fi

echo "⚙️ Setting up aichat configuration..."
AICHAT_CONFIG_DIR="$HOME/.config/aichat"
mkdir -p "$AICHAT_CONFIG_DIR"

# Set aichat config
if [ -f "${PROJECT_ROOT}/aichat/config.yaml" ]; then
    cp "${PROJECT_ROOT}/aichat/config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml"
elif [ -f "./aichat/config.yaml" ]; then
    cp "./aichat/config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml"
fi

# Handle OpenAI API key
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "🔑 Setting up aichat OpenAI API key..."
    sed -i.bak "s/OPENAI_API_KEY_PLACEHOLDER/$OPENAI_API_KEY/" "${AICHAT_CONFIG_DIR}/config.yaml" && rm "${AICHAT_CONFIG_DIR}/config.yaml.bak"
else
    echo "ℹ️ No OPENAI_API_KEY found. To set it later, run:"
    echo "sed -i.bak \"s/OPENAI_API_KEY_PLACEHOLDER/your-api-key-here/\" \$HOME/.config/aichat/config.yaml"
fi

echo "✅ Setup completed!"
