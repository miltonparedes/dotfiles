#!/bin/bash

set -e

echo "🚀 Starting development environment setup..."

if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

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

if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
elif [ -n "$USER" ]; then
    ACTUAL_USER="$USER"
else
    ACTUAL_USER=$(whoami)
fi

USER_HOME=$(eval echo ~${ACTUAL_USER})

echo "👤 Configuring for user: ${ACTUAL_USER} (home: ${USER_HOME})"

for SHELL_RC in "${USER_HOME}/.bashrc" "${USER_HOME}/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        if [ -f "${SCRIPT_DIR}/aliases" ]; then
            cat "${SCRIPT_DIR}/aliases" >> "$SHELL_RC"
        elif [ -f "./devcontainers/aliases" ]; then
            cat "./devcontainers/aliases" >> "$SHELL_RC"
        fi
        echo 'eval "$(zoxide init $(basename ${SHELL_RC%"rc"}))"' >> "$SHELL_RC"
    fi
done

echo "⚙️ Setting up lazygit configuration..."
LAZYGIT_CONFIG_DIR="${USER_HOME}/.config/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR"

if [ -f "${PROJECT_ROOT}/lazygit/config.yml" ]; then
    cp "${PROJECT_ROOT}/lazygit/config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml"
elif [ -f "./lazygit/config.yml" ]; then
    cp "./lazygit/config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml"
fi

chown -R ${ACTUAL_USER}:${ACTUAL_USER} "${USER_HOME}/.config" 2>/dev/null || true
chown ${ACTUAL_USER}:${ACTUAL_USER} "${USER_HOME}/.bashrc" "${USER_HOME}/.zshrc" 2>/dev/null || true

echo "✅ Setup completed!"
