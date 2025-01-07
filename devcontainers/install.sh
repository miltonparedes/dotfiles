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

# Create temporary directory for downloads with proper permissions
TEMP_DIR=$(mktemp -d)
if [ ! -d "$TEMP_DIR" ]; then
    echo "❌ Failed to create temporary directory"
    exit 1
fi

# Ensure temporary directory is writable
if [ ! -w "$TEMP_DIR" ]; then
    echo "❌ Temporary directory is not writable: $TEMP_DIR"
    exit 1
fi

echo "📁 Using temporary directory: $TEMP_DIR"
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

    if [ ! -f "$output" ]; then
        echo "❌ File not found after download: ${output}"
        return 1
    fi

    echo "✅ Successfully downloaded ${filename}"
    return 0
}

# Download necessary files
echo "📥 Downloading configuration files..."
declare -A FILE_MAPPINGS=(
    ["devcontainers/packages.sh"]="packages.sh"
    ["devcontainers/aliases"]="aliases"
    ["lazygit/config.yml"]="lazygit_config.yml"
    ["aichat/config.yaml"]="aichat_config.yaml"
)

for src in "${!FILE_MAPPINGS[@]}"; do
    dest="${FILE_MAPPINGS[$src]}"
    if ! download_file "${REPO_URL}/${src}" "${TEMP_DIR}/${dest}"; then
        echo "❌ Failed to download ${src}. Cleaning up and exiting..."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
done

# Debug: List downloaded files
echo "📁 Contents of temporary directory:"
ls -la "$TEMP_DIR"

# Make packages.sh executable
chmod +x "${TEMP_DIR}/packages.sh" || {
    echo "❌ Failed to make packages.sh executable"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Source the packages script
if [ -f "${TEMP_DIR}/packages.sh" ]; then
    echo "📦 Running packages installation..."
    source "${TEMP_DIR}/packages.sh"
else
    echo "❌ packages.sh not found in temporary directory"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "👤 Configuring environment..."

# Setup shell configurations
for SHELL_RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$SHELL_RC" ]; then
        echo "⚙️ Setting up aliases for $(basename ${SHELL_RC})..."
        
        if [ ! -f "${TEMP_DIR}/aliases" ]; then
            echo "❌ Aliases file not found at: ${TEMP_DIR}/aliases"
            echo "📁 Contents of temporary directory:"
            ls -la "$TEMP_DIR"
            continue
        fi
        
        if [ ! -r "${TEMP_DIR}/aliases" ]; then
            echo "❌ Aliases file is not readable at: ${TEMP_DIR}/aliases"
            continue
        fi

        # Backup original rc file
        cp "$SHELL_RC" "${SHELL_RC}.backup" || {
            echo "❌ Failed to create backup of ${SHELL_RC}"
            continue
        }

        # Append aliases
        if cat "${TEMP_DIR}/aliases" >> "$SHELL_RC"; then
            if echo 'source "$HOME/.cargo/env"' >> "$SHELL_RC"; then
                echo "✅ Successfully configured $(basename ${SHELL_RC})"
            else
                echo "❌ Failed to append cargo env to ${SHELL_RC}"
                # Restore backup
                mv "${SHELL_RC}.backup" "$SHELL_RC"
            fi
        else
            echo "❌ Failed to append aliases to ${SHELL_RC}"
            # Restore backup
            mv "${SHELL_RC}.backup" "$SHELL_RC"
        fi
    fi
done

# Setup lazygit configuration
echo "⚙️ Setting up lazygit configuration..."
LAZYGIT_CONFIG_DIR="$HOME/.config/lazygit"
mkdir -p "$LAZYGIT_CONFIG_DIR" || {
    echo "❌ Failed to create lazygit config directory"
    exit 1
}

if [ ! -f "${TEMP_DIR}/lazygit_config.yml" ]; then
    echo "❌ Lazygit config file not found in temporary directory"
    echo "📁 Contents of temporary directory:"
    ls -la "$TEMP_DIR"
else
    cp "${TEMP_DIR}/lazygit_config.yml" "${LAZYGIT_CONFIG_DIR}/config.yml" || {
        echo "❌ Failed to copy lazygit config file"
    }
fi

# Setup aichat configuration
echo "⚙️ Setting up aichat configuration..."
AICHAT_CONFIG_DIR="$HOME/.config/aichat"
mkdir -p "$AICHAT_CONFIG_DIR"

if [ ! -f "${TEMP_DIR}/aichat_config.yaml" ]; then
    echo "❌ Aichat config file not found in temporary directory"
    echo "📁 Contents of temporary directory:"
    ls -la "$TEMP_DIR"
else
    cp "${TEMP_DIR}/aichat_config.yaml" "${AICHAT_CONFIG_DIR}/config.yaml" || {
        echo "❌ Failed to copy aichat config file"
    }
fi

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
