config_dir := "~/.config"
zsh_aliases := "~/.zshrc.d/aliases"
bash_aliases := "~/.bashrc.d/aliases"
spell_cli_path := "~/.config/spell/cli.just"
spell_alias := 'alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"'
nvim_config_path := config_dir + "/nvim"

# Install or update custom CLI tool
install-spell:
    @echo "Inscribing or updating the Spell CLI..."
    @mkdir -p ~/.config/spell
    @cp -rf spell/* ~/.config/spell/
    @if [ -f ~/.zshrc.d/aliases ]; then \
        if grep -q "alias spell=" ~/.zshrc.d/aliases; then \
            if [ "$(uname)" = "Darwin" ]; then \
                sed -i '' 's|alias spell=.*|{{spell_alias}}|' ~/.zshrc.d/aliases; \
            else \
                sed -i 's|alias spell=.*|{{spell_alias}}|' ~/.zshrc.d/aliases; \
            fi; \
        else \
            echo '{{spell_alias}}' >> ~/.zshrc.d/aliases; \
        fi; \
    fi
    @if [ -f ~/.bashrc.d/aliases ]; then \
        if grep -q "alias spell=" ~/.bashrc.d/aliases; then \
            if [ "$(uname)" = "Darwin" ]; then \
                sed -i '' 's|alias spell=.*|{{spell_alias}}|' ~/.bashrc.d/aliases; \
            else \
                sed -i 's|alias spell=.*|{{spell_alias}}|' ~/.bashrc.d/aliases; \
            fi; \
        else \
            echo '{{spell_alias}}' >> ~/.bashrc.d/aliases; \
        fi; \
    fi
    @echo "Spell CLI inscribed or updated. Restart your terminal or source your aliases file to activate its powers"

install-brew-essential-cli-packages:
    @echo "Installing Homebrew packages..."
    brew update
    brew bundle --file cli.Brewfile
    brew upgrade
    brew cleanup

# Set foloder with aliases/functions for a zsh or bash shell
set-shell-functions shell:
    @echo "Setting aliases for {{shell}}..."
    @if [ "{{shell}}" = "zsh" ]; then \
        mkdir -p ~/.zshrc.d; \
        cp -R .zshrc.d/* ~/.zshrc.d/; \
    elif [ "{{shell}}" = "bash" ]; then \
        mkdir -p ~/.bashrc.d; \
        cp -R .bashrc.d/* ~/.bashrc.d/; \
    else \
        echo "Unsupported shell: {{shell}}"; \
        exit 1; \
    fi

lazygit-config path:
    @echo "Configuring lazygit..."
    @mkdir -p {{path}}/lazygit
    @cp -f lazygit/config.yml {{path}}/lazygit/config.yml

# Check if required dependencies are installed
check-nvim-deps:
    @echo "Checking Neovim dependencies..."
    @if ! command -v git >/dev/null 2>&1; then \
        echo "❌ git is required but not installed"; \
        exit 1; \
    fi
    @if ! command -v curl >/dev/null 2>&1; then \
        echo "❌ curl is required but not installed"; \
        exit 1; \
    fi
    @if ! command -v rg >/dev/null 2>&1; then \
        echo "❌ ripgrep is required but not installed"; \
        exit 1; \
    fi
    @if ! command -v nvim >/dev/null 2>&1; then \
        echo "❌ neovim is required but not installed"; \
        exit 1; \
    fi
    @echo "✅ All Neovim dependencies are installed"

# Install missing dependencies
install-nvim-deps:
    @echo "Installing Neovim dependencies..."
    @if [ "$(uname)" = "Darwin" ]; then \
        if ! command -v git >/dev/null 2>&1; then brew install git; fi; \
        if ! command -v curl >/dev/null 2>&1; then brew install curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then brew install ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then brew install neovim; fi; \
    elif command -v apt-get >/dev/null 2>&1; then \
        sudo apt-get update; \
        if ! command -v git >/dev/null 2>&1; then sudo apt-get install -y git; fi; \
        if ! command -v curl >/dev/null 2>&1; then sudo apt-get install -y curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then sudo apt-get install -y ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then sudo apt-get install -y neovim; fi; \
    elif command -v dnf >/dev/null 2>&1; then \
        if ! command -v git >/dev/null 2>&1; then sudo dnf install -y git; fi; \
        if ! command -v curl >/dev/null 2>&1; then sudo dnf install -y curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then sudo dnf install -y ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then sudo dnf install -y neovim; fi; \
    elif command -v pacman >/dev/null 2>&1; then \
        if ! command -v git >/dev/null 2>&1; then sudo pacman -S --noconfirm git; fi; \
        if ! command -v curl >/dev/null 2>&1; then sudo pacman -S --noconfirm curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then sudo pacman -S --noconfirm ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then sudo pacman -S --noconfirm neovim; fi; \
    else \
        echo "⚠️  Unknown package manager. Please install git, curl, ripgrep, and neovim manually"; \
    fi

# Backup existing Neovim configuration
backup-nvim-config:
    @echo "Backing up existing Neovim configuration..."
    @if [ -e {{nvim_config_path}} ]; then \
        backup_dir="{{nvim_config_path}}.backup.$(date +%Y%m%d_%H%M%S)"; \
        echo "📦 Creating backup: $backup_dir"; \
        mv {{nvim_config_path}} "$backup_dir"; \
        echo "✅ Backup created successfully"; \
    else \
        echo "ℹ️  No existing Neovim configuration found"; \
    fi

# Install Neovim configuration
install-nvim-config:
    @echo "Installing Neovim configuration..."
    @mkdir -p ~/.config
    @echo "🔗 Creating symlink: $(pwd)/nvim -> {{nvim_config_path}}"
    @ln -sf $(pwd)/nvim {{nvim_config_path}}
    @echo "✅ Neovim configuration installed"

# Trigger Lazy plugin installation
install-nvim-plugins:
    @echo "Installing Neovim plugins..."
    @if nvim --headless "+quitall" 2>/dev/null; then \
        echo "✅ Neovim plugins installed successfully"; \
    else \
        echo "⚠️  Plugin installation may have encountered issues (this is often normal on first run)"; \
    fi

# Update Neovim plugins
update-nvim-plugins:
    @echo "Updating Neovim plugins..."
    @if nvim --headless "+Lazy! sync +qa" 2>/dev/null; then \
        echo "✅ Neovim plugins updated successfully"; \
    else \
        echo "⚠️  Plugin update may have encountered issues"; \
    fi

install-mac-os-config:
    @echo "Installing configuration for macOS (zsh)..."
    just set-shell-functions zsh
    just lazygit-config "~/Library/Application\ Support"

install-bluefin-config:
    just lazygit-config "~/.config"
    just set-shell-functions bash

# Install OS-specific configuration
install-os-config:
    @echo "Detecting and configuring OS..."
    @if [ "$(uname)" = "Darwin" ]; then \
        echo "macOS detected. Installing configuration..."; \
        just set-shell-functions zsh; \
        just lazygit-config "~/Library/Application\ Support"; \
    elif [ "$(grep -i fedora /etc/os-release)" ]; then \
        echo "Bluefin detected. Installing configuration..."; \
        just lazygit-config "{{config_dir}}"; \
        just set-shell-functions bash; \
    else \
        echo "Unrecognized operating system"; \
        exit 1; \
    fi

# Install Neovim configuration (complete setup)
install-nvim:
    @echo "🚀 Installing Neovim configuration..."
    just install-nvim-deps || true
    just backup-nvim-config
    just install-nvim-config
    just install-nvim-plugins
    @echo "✅ Neovim installation complete!"

# Update Neovim setup
update-nvim:
    @echo "🔄 Updating Neovim configuration..."
    just install-nvim-config
    just update-nvim-plugins
    @echo "✅ Neovim update complete!"

install:
    @echo "Starting installation..."
    @if ! just install-brew-essential-cli-packages; then \
        echo "Error installing Homebrew packages"; \
        exit 1; \
    fi
    @if ! just install-os-config; then \
        echo "Error installing OS-specific configuration"; \
        exit 1; \
    fi
    @if ! just install-spell; then \
        echo "Error installing Spell CLI"; \
        exit 1; \
    fi
    @if ! just install-nvim; then \
        echo "Error installing Neovim configuration"; \
        exit 1; \
    fi
    @echo "Installation complete"
