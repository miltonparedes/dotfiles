nvim_config_path := "~/.config/nvim"
agents_repo := env_var_or_default("AGENTS_REPO", "~/Workspaces/P/agents")

# Chezmoi shortcuts
apply:
    chezmoi apply -v

diff:
    chezmoi diff

# Full installation: brew + chezmoi + kitmux + nvim
install:
    @echo "Starting full installation..."
    just install-brew-essential-cli-packages
    chezmoi apply -v
    just install-kitmux
    just install-nvim-plugins
    @echo "Installation complete!"
    @echo ""
    @echo "Next steps:"
    @echo "1. Start Fish shell: fish"
    @echo "2. Make Fish your default shell: chsh -s $(which fish)"
    @echo "3. Start TMUX: tmux"

# Install Homebrew packages
install-brew-essential-cli-packages:
    @echo "Installing Homebrew packages..."
    brew update
    brew bundle --file cli.Brewfile
    brew upgrade
    brew cleanup

# Build and install kitmux (TUI tmux session manager)
install-kitmux:
    #!/usr/bin/env bash
    echo "Building kitmux..."
    cd ~/Workspaces/M/kitmux && GOPROXY=direct go build -ldflags="-s -w" -o "$(go env GOPATH)/bin/kitmux" .
    echo "kitmux installed to $(go env GOPATH)/bin/kitmux"

# Trigger Lazy plugin installation
install-nvim-plugins:
    @echo "Installing Neovim plugins..."
    @if nvim --headless "+quitall" 2>/dev/null; then \
        echo "Neovim plugins installed successfully"; \
    else \
        echo "Plugin installation may have encountered issues (this is often normal on first run)"; \
    fi

# Update Neovim plugins
update-nvim-plugins:
    @echo "Updating Neovim plugins..."
    @if nvim --headless "+Lazy! sync +qa" 2>/dev/null; then \
        echo "Neovim plugins updated successfully"; \
    else \
        echo "Plugin update may have encountered issues"; \
    fi

# Install Neovim dependencies
install-nvim-deps:
    @echo "Installing Neovim dependencies..."
    @if [ "$(uname)" = "Darwin" ]; then \
        if ! command -v git >/dev/null 2>&1; then brew install git; fi; \
        if ! command -v curl >/dev/null 2>&1; then brew install curl; fi; \
        if ! command -v rg >/dev/null 2>&1; then brew install ripgrep; fi; \
        if ! command -v nvim >/dev/null 2>&1; then brew install neovim; fi; \
    elif command -v rpm-ostree >/dev/null 2>&1; then \
        echo "Fedora Atomic/Bazzite detected - using Homebrew..."; \
        if ! command -v brew >/dev/null 2>&1; then \
            echo "Homebrew not installed. Install with:"; \
            echo "  /bin/bash -c \"\$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
            exit 1; \
        fi; \
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
        echo "Unknown package manager. Please install git, curl, ripgrep, and neovim manually"; \
    fi

# Install JetBrains Mono Nerd Font (for terminal and nvim icons)
install-fonts:
    #!/usr/bin/env bash
    echo "Installing JetBrains Mono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [ -d "$FONT_DIR" ] && [ "$(ls -A $FONT_DIR 2>/dev/null)" ]; then
        echo "JetBrains Mono Nerd Font already installed"
    else
        mkdir -p "$FONT_DIR"
        cd "$FONT_DIR"
        echo "Downloading from GitHub releases..."
        curl -sOL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
        tar -xf JetBrainsMono.tar.xz
        rm JetBrainsMono.tar.xz
        fc-cache -fv ~/.local/share/fonts > /dev/null 2>&1
        echo "JetBrains Mono Nerd Font installed"
    fi

# Check if required dependencies are installed
check-deps:
    @echo "Checking dependencies..."
    @missing=0; \
    for cmd in fish starship tmux nvim git rg fzf zoxide eza bat delta chezmoi; do \
        if ! command -v $$cmd >/dev/null 2>&1; then \
            echo "  $$cmd is not installed"; \
            missing=1; \
        else \
            echo "  $$cmd is installed"; \
        fi; \
    done; \
    if [ $$missing -eq 1 ]; then \
        echo ""; \
        echo "Install missing dependencies with:"; \
        echo "  just install-brew-essential-cli-packages"; \
        exit 1; \
    fi
    @echo "All dependencies are installed"

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

# Install Linux clipboard tools for SSH/remote usage
install-linux-ssh-tools:
    @echo "Installing Linux SSH/clipboard tools..."
    @if command -v dnf >/dev/null 2>&1; then \
        sudo dnf install -y xclip wl-clipboard fd-find; \
    elif command -v apt-get >/dev/null 2>&1; then \
        sudo apt-get install -y xclip wl-clipboard fd-find; \
    elif command -v pacman >/dev/null 2>&1; then \
        sudo pacman -S --noconfirm xclip wl-clipboard fd; \
    else \
        echo "Unknown package manager. Install xclip, wl-clipboard manually"; \
    fi
    @echo "Linux SSH tools installed"

# Show help
help:
    @echo "Available commands:"
    @echo ""
    @echo "Chezmoi:"
    @echo "  just apply                # chezmoi apply -v"
    @echo "  just diff                 # chezmoi diff"
    @echo ""
    @echo "Installation:"
    @echo "  just install              # Full install (brew + chezmoi + kitmux + nvim)"
    @echo "  just install-brew-essential-cli-packages  # Homebrew packages"
    @echo "  just install-kitmux       # Build kitmux session manager"
    @echo "  just install-nvim-plugins # Install Neovim plugins"
    @echo "  just install-nvim-deps    # Install Neovim dependencies"
    @echo "  just install-fonts        # Install JetBrains Mono Nerd Font"
    @echo ""
    @echo "Maintenance:"
    @echo "  just update-nvim-plugins  # Update Neovim plugins"
    @echo "  just check-deps           # Check dependencies"
    @echo "  just switch-to-fish       # Guide to switch to Fish shell"
    @echo "  just install-linux-ssh-tools  # Linux clipboard tools"

# Default command
default: help
