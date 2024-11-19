#!/bin/bash

set -e

echo "🚀 Starting development environment setup..."

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Install packages
source ./packages.sh

# Get non-root user (assuming it exists)
ACTUAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd ${ACTUAL_USER} | cut -d: -f6)

echo "👤 Configuring for user: ${ACTUAL_USER}"

# Configure aliases and shell
for SHELL_RC in "${USER_HOME}/.bashrc" "${USER_HOME}/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        cat ./aliases >> "$SHELL_RC"
        echo 'eval "$(zoxide init $(basename ${SHELL_RC%"rc"}))"' >> "$SHELL_RC"
    fi
done

# Setup lazygit configuration
echo "⚙️ Setting up lazygit configuration..."
LAZYGIT_CONFIG_DIR="${USER_HOME}/.config/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR"

# Copy original lazygit config
cp ../lazygit/config.yml "${LAZYGIT_CONFIG_DIR}/config.yml"

# Set correct permissions
chown -R ${ACTUAL_USER}:${ACTUAL_USER} "${USER_HOME}/.config" 2>/dev/null || true
chown ${ACTUAL_USER}:${ACTUAL_USER} "${USER_HOME}/.bashrc" "${USER_HOME}/.zshrc" 2>/dev/null || true

echo "✅ Setup completed!"
