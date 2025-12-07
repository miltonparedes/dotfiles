config_dir := "~/.config"
fish_config := "~/.config/fish"
spell_cli_path := "~/.config/spell/cli.just"
nvim_config_path := config_dir + "/nvim"

# Install or update custom CLI tool (Spell)
install-spell:
    @echo "Inscribing or updating the Spell CLI..."
    @mkdir -p ~/.config/spell
    @cp -rf spell/* ~/.config/spell/
    @if [ -d ~/.config/fish ]; then \
        echo "alias spell 'just --justfile ~/.config/spell/cli.just --working-directory ~'" > ~/.config/fish/conf.d/spell.fish; \
    fi
    @echo "Spell CLI inscribed or updated. Restart your terminal or run 'reload' in Fish"

# Install Homebrew packages
install-brew-essential-cli-packages:
    @echo "Installing Homebrew packages..."
    brew update
    brew bundle --file cli.Brewfile
    brew upgrade
    brew cleanup

# Install fish shell configuration
install-fish:
    @echo "Installing Fish shell configuration..."
    @mkdir -p ~/.config/fish
    @cp -R fish/* ~/.config/fish/
    @echo "✅ Fish configuration installed successfully"
    @echo "Run 'fish' to start using Fish shell"

# Install Starship prompt configuration
install-starship:
    @echo "Installing Starship configuration..."
    @mkdir -p ~/.config
    @cp -f starship.toml ~/.config/starship.toml
    @echo "✅ Starship configuration installed"

# Install TMUX configuration
install-tmux:
    @echo "Installing TMUX configuration..."
    @cp -f tmux.conf ~/.tmux.conf
    @echo "✅ TMUX configuration installed"
    @echo "Restart TMUX or run: tmux source-file ~/.tmux.conf"

# Install Lazygit configuration
lazygit-config path:
    @echo "Configuring lazygit..."
    @mkdir -p {{path}}/lazygit
    @cp -f lazygit/config.yml {{path}}/lazygit/config.yml

# Check if required dependencies are installed
check-deps:
    @echo "Checking dependencies..."
    @missing=0; \
    for cmd in fish starship tmux nvim git rg fzf zoxide eza bat; do \
        if ! command -v $$cmd >/dev/null 2>&1; then \
            echo "❌ $$cmd is not installed"; \
            missing=1; \
        else \
            echo "✅ $$cmd is installed"; \
        fi; \
    done; \
    if [ $$missing -eq 1 ]; then \
        echo ""; \
        echo "Install missing dependencies with:"; \
        echo "  just install-brew-essential-cli-packages"; \
        exit 1; \
    fi
    @echo "✅ All dependencies are installed"

# Check Neovim dependencies
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
    elif command -v dnf >/dev/null 2>&1; then \
        if ! command -v git >/dev/null 2>&1; then sudo dnf install -y git; fi; \
        if ! command -v curl >/dev/null 2>&1; then sudo dnf install -y curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then sudo dnf install -y ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then sudo dnf install -y neovim; fi; \
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

# Install configuration for macOS
install-mac-os-config:
    @echo "Installing configuration for macOS..."
    just install-fish
    just install-starship
    just install-tmux
    just lazygit-config "~/Library/Application\ Support"
    @echo "✅ macOS configuration installed"

# Install configuration for Bluefin/Fedora
install-bluefin-config:
    @echo "Installing configuration for Bluefin/Fedora..."
    just install-fish
    just install-starship
    just install-tmux
    just lazygit-config "~/.config"
    @echo "✅ Bluefin/Fedora configuration installed"

# Install OS-specific configuration
install-os-config:
    @echo "Detecting and configuring OS..."
    @if [ "$(uname)" = "Darwin" ]; then \
        echo "macOS detected."; \
        just install-mac-os-config; \
    elif [ -f /etc/fedora-release ] || [ -f /etc/os-release ] && grep -qi fedora /etc/os-release; then \
        echo "Bluefin/Fedora detected."; \
        just install-bluefin-config; \
    else \
        echo "Unrecognized operating system"; \
        echo "Manually run: just install-fish && just install-starship && just install-tmux"; \
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

# Full installation
install:
    @echo "Starting full installation..."
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
    @echo "✅ Installation complete!"
    @echo ""
    @echo "Next steps:"
    @echo "1. Start Fish shell: fish"
    @echo "2. Make Fish your default shell: chsh -s $(which fish)"
    @echo "3. Start TMUX: tmux"

# Switch to fish shell as default
switch-to-fish:
    @echo "Switching to Fish shell..."
    @if command -v fish >/dev/null 2>&1; then \
        echo "Fish is installed at: $$(which fish)"; \
        echo ""; \
        echo "To make Fish your default shell, run:"; \
        echo "  chsh -s $$(which fish)"; \
        echo ""; \
        echo "You may need to add Fish to /etc/shells first:"; \
        echo "  echo $$(which fish) | sudo tee -a /etc/shells"; \
        echo ""; \
        echo "Or start Fish now with: fish"; \
    else \
        echo "Fish is not installed. Install it first with:"; \
        if [ "$(uname)" = "Darwin" ]; then \
            echo "  brew install fish"; \
        else \
            echo "  sudo dnf install fish  # For Fedora/Bluefin"; \
        fi; \
    fi

# Update all configurations
update:
    @echo "Updating all configurations..."
    just install-fish
    just install-starship
    just install-tmux
    just update-nvim
    @echo "✅ All configurations updated!"

# Check system setup
check:
    @echo "Checking system setup..."
    just check-deps
    @echo ""
    @echo "Configuration status:"
    @if [ -d ~/.config/fish ]; then \
        echo "✅ Fish configuration installed"; \
    else \
        echo "❌ Fish configuration not installed"; \
    fi
    @if [ -f ~/.config/starship.toml ]; then \
        echo "✅ Starship configuration installed"; \
    else \
        echo "❌ Starship configuration not installed"; \
    fi
    @if [ -f ~/.tmux.conf ]; then \
        echo "✅ TMUX configuration installed"; \
    else \
        echo "❌ TMUX configuration not installed"; \
    fi
    @if [ -L ~/.config/nvim ] || [ -d ~/.config/nvim ]; then \
        echo "✅ Neovim configuration installed"; \
    else \
        echo "❌ Neovim configuration not installed"; \
    fi

# Show help
help:
    @echo "Available commands:"
    @echo "  just install              # Full installation"
    @echo "  just install-fish         # Install Fish configuration"
    @echo "  just install-starship     # Install Starship prompt"
    @echo "  just install-tmux         # Install TMUX configuration"
    @echo "  just install-nvim         # Install Neovim configuration"
    @echo "  just install-spell        # Install Spell CLI tool"
    @echo "  just update               # Update all configurations"
    @echo "  just update-nvim          # Update Neovim plugins"
    @echo "  just switch-to-fish       # Instructions to switch to Fish"
    @echo "  just check                # Check system setup"
    @echo "  just check-deps           # Check dependencies"
    @echo "  just help                 # Show this help"

# Default command
default: help