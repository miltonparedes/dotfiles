config_dir := "~/.config"
zsh_aliases := "~/.zshrc.d/aliases"
bash_aliases := "~/.bashrc.d/aliases"
spell_cli_path := "~/.config/spell/cli.just"
spell_alias := 'alias spell="just --justfile ~/.config/spell/cli.just --working-directory ~"'

install-python-dependencies:
    @echo "Installing Python dependencies..."
    @uv pip install -r requirements.txt --system --break-system-packages

compile-python-dependencies:
    @echo "Compiling Python dependencies..."
    @uv pip compile requirements.in > requirements.txt

# Install or update custom CLI tool
install-spell:
    @echo "Inscribing or updating the Spell CLI..."
    @mkdir -p ~/.config/spell
    @cp -f spell/cli.just ~/.config/spell/cli.just
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
    @mkdir -p '{{path}}/lazygit'
    @cp -f lazygit/config.yml {{path}}/lazygit/config.yml

install-mac-os-config: install-python-dependencies
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
    @echo "Installation complete"
