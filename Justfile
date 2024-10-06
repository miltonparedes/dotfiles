# Install configurations
install:
    @echo "Installing configurations..."
    # Commands to install your dotfiles would go here

# Install or update custom CLI tool
install-cli:
    @echo "Inscribing or updating the Spell CLI..."
    @mkdir -p ~/.config/spell
    @cp -f spell/cli.just ~/.config/spell/cli.just
    @if [ -f ~/.zshrc.d/aliases ]; then \
        if grep -q "alias spell=" ~/.zshrc.d/aliases; then \
            sed -i '' 's|alias spell=.*|alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"|' ~/.zshrc.d/aliases; \
        else \
            echo 'alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"' >> ~/.zshrc.d/aliases; \
        fi; \
    fi
    @if [ -f ~/.bashrc.d/aliases ]; then \
        if grep -q "alias spell=" ~/.bashrc.d/aliases; then \
            sed -i 's|alias spell=.*|alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"|' ~/.bashrc.d/aliases; \
        else \
            echo 'alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"' >> ~/.bashrc.d/aliases; \
        fi; \
    fi
    @echo "Spell CLI inscribed or updated. Restart your terminal or source your aliases file to activate its powers"

# Detect operating system
detect-os:
    @echo "Detecting operating system..."
    @if [ "$(uname)" = "Darwin" ]; then \
        echo "macOS detected"; \
    elif [ "$(grep -i fedora /etc/os-release)" ]; then \
        echo "Fedora detected"; \
    else \
        echo "Unrecognized operating system"; \
    fi

# Install OS-specific configuration
install-os-config: detect-os
    @if [ "$(uname)" = "Darwin" ]; then \
        echo "Installing configuration for macOS (zsh)..."; \
        # Commands to install macOS configuration \
    elif [ "$(grep -i fedora /etc/os-release)" ]; then \
        echo "Installing configuration for Fedora (bash)..."; \
        # Commands to install Fedora configuration \
    else \
        echo "Cannot install OS-specific configuration"; \
    fi

# Install everything
install-all: install install-cli install-os-config
    @echo "Installation complete"
