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
# Load OPENAI_API_KEY from .env file
ENV_FILE="${PROJECT_ROOT}/.env"
if [ -f "$ENV_FILE" ]; then
    echo "📄 Loading OPENAI_API_KEY from .env file..."
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

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

if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ Error: OPENAI_API_KEY environment variable is not set."
    echo "Please make sure it's defined in ../.env file or as an environment variable."
    exit 1
fi

echo "🔑 Setting up aichat OpenAI API key..."
if [ -f "${PROJECT_ROOT}/aichat/config.yaml" ]; then
    cp "${PROJECT_ROOT}/aichat/config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml"
    sed -i.bak "s/OPENAI_API_KEY_PLACEHOLDER/$OPENAI_API_KEY/" "${AICHAT_CONFIG_DIR}/config.yaml" && rm "${AICHAT_CONFIG_DIR}/config.yaml.bak"
elif [ -f "./aichat/config.yaml" ]; then
    cp "./aichat/config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml"
    sed -i.bak "s/OPENAI_API_KEY_PLACEHOLDER/$OPENAI_API_KEY/" "${AICHAT_CONFIG_DIR}/config.yaml" && rm "${AICHAT_CONFIG_DIR}/config.yaml.bak"
fi

echo "✅ Setup completed!"
