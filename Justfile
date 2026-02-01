config_dir := "~/.config"
fish_config := "~/.config/fish"
spell_cli_path := "~/.config/spell/cli.just"
nvim_config_path := config_dir + "/nvim"
backup_dir := "~/.config-backups"
dry_run := env_var_or_default("DRY_RUN", "")
backup_enabled := env_var_or_default("BACKUP", "1")

# Helper: Get diff command based on available tools
[private]
get-diff-cmd:
    @if command -v delta >/dev/null 2>&1; then \
        echo "delta"; \
    elif command -v colordiff >/dev/null 2>&1; then \
        echo "colordiff -u"; \
    else \
        echo "diff -u"; \
    fi

# Helper: Backup a single file before overwriting
[private]
backup-file dest config_name:
    #!/usr/bin/env bash
    if [ "{{ backup_enabled }}" = "1" ] && [ -e "{{ dest }}" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_path="$HOME/.config-backups/{{ config_name }}/$timestamp"
        mkdir -p "$backup_path"
        cp -a "{{ dest }}" "$backup_path/"
        echo "  📦 Backup: {{ dest }} -> $backup_path"
    fi

# Helper: Backup a directory before overwriting
[private]
backup-directory dest config_name:
    #!/usr/bin/env bash
    if [ "{{ backup_enabled }}" = "1" ] && [ -d "{{ dest }}" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        backup_path="$HOME/.config-backups/{{ config_name }}/$timestamp"
        mkdir -p "$backup_path"
        cp -a "{{ dest }}/." "$backup_path/"
        echo "  📦 Backup: {{ dest }} -> $backup_path"
    fi

# Helper: Show diff between source and destination
[private]
show-diff src dest:
    #!/usr/bin/env bash
    if [ -e "{{ dest }}" ]; then
        diff_cmd=$(just get-diff-cmd)
        echo ""
        echo "📋 Changes for {{ dest }}:"
        $diff_cmd "{{ dest }}" "{{ src }}" 2>/dev/null || true
    else
        echo "  [NEW] {{ dest }} (file does not exist yet)"
    fi

# Install or update custom CLI tool (Spell)
install-spell:
    #!/usr/bin/env bash
    echo "Inscribing or updating the Spell CLI..."
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install: spell/* -> ~/.config/spell/"
        echo "Files that would be copied:"
        find spell -type f -exec echo "  {}" \;
        if [ -d ~/.config/fish ]; then
            echo "[DRY-RUN] Would create: ~/.config/fish/conf.d/spell.fish"
        fi
    else
        mkdir -p ~/.config/spell
        just backup-directory ~/.config/spell spell
        cp -rf spell/* ~/.config/spell/
        if [ -d ~/.config/fish ]; then
            echo "alias spell 'just --justfile ~/.config/spell/cli.just --working-directory ~'" > ~/.config/fish/conf.d/spell.fish
        fi
        echo "✅ Spell CLI inscribed or updated. Restart your terminal or run 'reload' in Fish"
    fi

# Install Homebrew packages
install-brew-essential-cli-packages:
    @echo "Installing Homebrew packages..."
    brew update
    brew bundle --file cli.Brewfile
    brew upgrade
    brew cleanup

# Install fish shell configuration
install-fish:
    #!/usr/bin/env bash
    echo "Installing Fish shell configuration..."
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install: fish/ -> ~/.config/fish/"
        echo ""
        echo "Files that would be copied:"
        find fish -type f ! -name '*.template' -exec echo "  {}" \;
        echo ""
        echo "[DRY-RUN] Would install secrets from .env into ~/.config/fish/conf.d/secrets.fish"
        echo ""
        echo "Checking for changes in existing files:"
        for f in $(find fish -type f ! -name '*.template'); do
            dest="$HOME/.config/$f"
            if [ -f "$dest" ]; then
                just show-diff "$f" "$dest"
            else
                echo "  [NEW] ~/.config/$f"
            fi
        done
    else
        mkdir -p ~/.config/fish
        just backup-directory ~/.config/fish fish
        rsync -av --exclude '*.template' fish/ ~/.config/fish/
        just install-secrets
        echo "✅ Fish configuration installed successfully"
        echo "Run 'fish' to start using Fish shell"
    fi

# Install Starship prompt configuration
install-starship:
    #!/usr/bin/env bash
    echo "Installing Starship configuration..."
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install: starship.toml -> ~/.config/starship.toml"
        just show-diff starship.toml ~/.config/starship.toml
    else
        mkdir -p ~/.config
        just backup-file ~/.config/starship.toml starship
        cp -f starship.toml ~/.config/starship.toml
        echo "✅ Starship configuration installed"
    fi

# Install TMUX configuration
install-tmux:
    #!/usr/bin/env bash
    echo "Installing TMUX configuration..."
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  tmux.conf -> ~/.tmux.conf"
        echo "  tmux/*.conf -> ~/.config/tmux/"
        echo "  tmux/*.sh -> ~/.config/tmux/ (scripts)"
        just show-diff tmux.conf ~/.tmux.conf
        for f in tmux/*.conf; do
            dest="$HOME/.config/tmux/$(basename $f)"
            just show-diff "$f" "$dest"
        done
    else
        mkdir -p ~/.config/tmux
        just backup-file ~/.tmux.conf tmux
        just backup-directory ~/.config/tmux tmux
        cp -f tmux.conf ~/.tmux.conf
        cp -f tmux/*.conf ~/.config/tmux/
        cp -f tmux/*.sh ~/.config/tmux/ 2>/dev/null || true
        chmod +x ~/.config/tmux/*.sh 2>/dev/null || true
        echo "✅ TMUX configuration installed"
        echo "Restart TMUX or run: tmux source-file ~/.tmux.conf"
    fi

# Install git configuration (delta pager)
install-gitconfig:
    #!/usr/bin/env bash
    echo "Installing git configuration..."
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install: git/config -> ~/.config/git/config"
        just show-diff git/config ~/.config/git/config
    else
        mkdir -p ~/.config/git
        just backup-file ~/.config/git/config git
        cp -f git/config ~/.config/git/config
        echo "✅ Git configuration installed (delta pager enabled)"
    fi

# Install Lazygit configuration (auto-detects platform)
install-lazygit:
    #!/usr/bin/env bash
    echo "Installing Lazygit configuration..."
    # Auto-detect config path based on OS
    if [[ "$(uname)" == "Darwin" ]]; then
        config_base="$HOME/Library/Application Support"
    else
        config_base="$HOME/.config"
    fi
    dest_dir="$config_base/lazygit"
    dest_config="$dest_dir/config.yml"
    dest_commit_script="$dest_dir/lazycommit-commit.sh"
    dest_prompt_checkpoint="$dest_dir/lazycommit.prompts.checkpoint.yaml"
    dest_prompt_final="$dest_dir/lazycommit.prompts.final.yaml"

    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  lazygit/config.yml -> $dest_config"
        echo "  lazygit/lazycommit-commit.sh -> $dest_commit_script"
        echo "  lazygit/lazycommit.prompts.checkpoint.yaml -> $dest_prompt_checkpoint"
        echo "  lazygit/lazycommit.prompts.final.yaml -> $dest_prompt_final"
        just show-diff lazygit/config.yml "$dest_config"
    else
        mkdir -p "$dest_dir"
        just backup-file "$dest_config" lazygit
        cp -f lazygit/config.yml "$dest_config"
        cp -f lazygit/lazycommit-commit.sh "$dest_commit_script"
        cp -f lazygit/lazycommit.prompts.checkpoint.yaml "$dest_prompt_checkpoint"
        cp -f lazygit/lazycommit.prompts.final.yaml "$dest_prompt_final"
        chmod +x "$dest_commit_script"
        # Update lazygit paths in config based on actual destination
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' "s|~/.config/lazygit/|$dest_dir/|g" "$dest_config"
        else
            sed -i "s|~/.config/lazygit/|$dest_dir/|g" "$dest_config"
        fi
        echo "✅ Lazygit configuration installed to: $dest_dir"
    fi

# Install secrets (API keys) from .env file
install-secrets:
    @echo "Installing secrets from .env..."
    @if [ -f .env ]; then \
        . ./.env && \
        if [ -n "$GEMINI_API_KEY" ]; then \
            sed "s/GEMINI_API_KEY_PLACEHOLDER/$GEMINI_API_KEY/" \
                fish/conf.d/secrets.fish.template > ~/.config/fish/conf.d/secrets.fish && \
            echo "✅ Secrets installed to ~/.config/fish/conf.d/secrets.fish"; \
        else \
            echo "⚠️  GEMINI_API_KEY not found in .env"; \
        fi; \
    else \
        echo "⚠️  .env file not found. Copy sample.env to .env and add your keys."; \
    fi

# Check if required dependencies are installed
check-deps:
    @echo "Checking dependencies..."
    @missing=0; \
    for cmd in fish starship tmux nvim git rg fzf zoxide eza bat delta; do \
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

# Backup existing Neovim configuration
backup-nvim-config:
    @echo "Backing up existing Neovim configuration..."
    @if [ -e {{ nvim_config_path }} ]; then \
        backup_dir="{{ nvim_config_path }}.backup.$(date +%Y%m%d_%H%M%S)"; \
        echo "📦 Creating backup: $backup_dir"; \
        mv {{ nvim_config_path }} "$backup_dir"; \
        echo "✅ Backup created successfully"; \
    else \
        echo "ℹ️  No existing Neovim configuration found"; \
    fi

# Install Neovim configuration
install-nvim-config:
    @echo "Installing Neovim configuration..."
    @mkdir -p ~/.config
    @if [ -d {{ nvim_config_path }} ] && [ ! -L {{ nvim_config_path }} ]; then \
        echo "⚠️  Removing existing directory (backup should exist)..."; \
        rm -rf {{ nvim_config_path }}; \
    fi
    @echo "🔗 Creating symlink: $(pwd)/nvim -> {{ nvim_config_path }}"
    @ln -sfn $(pwd)/nvim {{ nvim_config_path }}
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
    just install-gitconfig
    just install-lazygit
    just install-secrets
    @echo "✅ macOS configuration installed"

# Install configuration for ublue (Bazzite, Bluefin, Aurora, etc.)
install-ublue-config:
    @echo "Installing configuration for ublue..."
    just install-fonts
    just install-fish
    just install-starship
    just install-tmux
    just install-gitconfig
    just install-lazygit
    just install-ghostty
    just install-secrets
    @echo "✅ ublue configuration installed"

# Install OS-specific configuration
install-os-config:
    @echo "Detecting and configuring OS..."
    @if [ "$(uname)" = "Darwin" ]; then \
        echo "macOS detected."; \
        just install-mac-os-config; \
    elif [ -f /etc/os-release ] && grep -qiE "(bazzite|bluefin|aurora)" /etc/os-release; then \
        echo "ublue detected."; \
        just install-ublue-config; \
    elif [ -f /etc/fedora-release ]; then \
        echo "Fedora detected."; \
        just install-ublue-config; \
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

# Check if running over SSH
check-ssh-session:
    @if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then \
        echo "📡 Running over SSH session"; \
        echo "  SSH_CLIENT: $SSH_CLIENT"; \
        echo "  SSH_TTY: $SSH_TTY"; \
    else \
        echo "💻 Local session detected"; \
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
        echo "⚠️  Unknown package manager. Install xclip, wl-clipboard manually"; \
    fi
    @echo "✅ Linux SSH tools installed"
    @echo "ℹ️  Neovim uses OSC52 for clipboard over SSH (works in modern terminals)"

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
    @if [ -f ~/.config/git/config ]; then \
        echo "✅ Git configuration installed (delta pager)"; \
    else \
        echo "❌ Git configuration not installed"; \
    fi
    @if [ -L ~/.config/nvim ] || [ -d ~/.config/nvim ]; then \
        echo "✅ Neovim configuration installed"; \
    else \
        echo "❌ Neovim configuration not installed"; \
    fi

# Preview all changes without making them (dry-run)
check-changes:
    @echo "Previewing all configuration changes..."
    @echo "=========================================="
    DRY_RUN=1 just install-fish
    @echo ""
    DRY_RUN=1 just install-starship
    @echo ""
    DRY_RUN=1 just install-tmux
    @echo ""
    DRY_RUN=1 just install-gitconfig
    @echo ""
    @echo "=========================================="
    @echo "Run 'just install-os-config' to apply these changes"

# Show diff for a specific config
diff-config config:
    #!/usr/bin/env bash
    diff_cmd=$(just get-diff-cmd)
    case "{{ config }}" in
        fish)
            for f in $(find fish -type f ! -name '*.template'); do
                dest="$HOME/.config/$f"
                if [ -f "$dest" ]; then
                    echo "=== $f ==="
                    $diff_cmd "$dest" "$f" 2>/dev/null || true
                fi
            done
            ;;
        git)
            $diff_cmd ~/.config/git/config git/config 2>/dev/null || true
            ;;
        tmux)
            echo "=== tmux.conf ==="
            $diff_cmd ~/.tmux.conf tmux.conf 2>/dev/null || true
            for f in tmux/*.conf; do
                dest="$HOME/.config/tmux/$(basename $f)"
                if [ -f "$dest" ]; then
                    echo "=== $f ==="
                    $diff_cmd "$dest" "$f" 2>/dev/null || true
                fi
            done
            ;;
        starship)
            $diff_cmd ~/.config/starship.toml starship.toml 2>/dev/null || true
            ;;
        claude)
            echo "=== settings.json ==="
            $diff_cmd ~/.claude/settings.json claude/settings.json 2>/dev/null || true
            echo "=== statusline.sh ==="
            $diff_cmd ~/.claude/statusline.sh claude/statusline.sh 2>/dev/null || true
            ;;
        gemini)
            echo "=== settings.json ==="
            $diff_cmd ~/.gemini/settings.json gemini/settings.json 2>/dev/null || true
            echo "=== extension-enablement.json ==="
            $diff_cmd ~/.gemini/extensions/extension-enablement.json gemini/extension-enablement.json 2>/dev/null || true
            ;;
        codex)
            echo "=== config.toml ==="
            $diff_cmd ~/.codex/config.toml codex/config.toml 2>/dev/null || true
            ;;
        *)
            echo "Unknown config: {{ config }}"
            echo "Available: fish, git, tmux, starship, claude, gemini, codex"
            exit 1
            ;;
    esac

# List all configuration backups
list-backups:
    @echo "Configuration backups in ~/.config-backups:"
    @if [ -d ~/.config-backups ]; then \
        find ~/.config-backups -mindepth 2 -maxdepth 2 -type d | sort; \
    else \
        echo "  No backups found"; \
    fi

# Restore a specific backup
restore-backup config timestamp:
    #!/usr/bin/env bash
    backup_path="$HOME/.config-backups/{{ config }}/{{ timestamp }}"
    if [ ! -d "$backup_path" ]; then
        echo "Backup not found: $backup_path"
        echo "Available backups:"
        just list-backups
        exit 1
    fi
    echo "Restoring {{ config }} from {{ timestamp }}..."
    case "{{ config }}" in
        fish)
            rm -rf ~/.config/fish
            cp -a "$backup_path" ~/.config/fish
            ;;
        git)
            cp -a "$backup_path/config" ~/.config/git/config
            ;;
        tmux)
            if [ -f "$backup_path/.tmux.conf" ]; then
                cp -a "$backup_path/.tmux.conf" ~/.tmux.conf
            fi
            if [ -d "$backup_path" ] && ls "$backup_path"/*.conf >/dev/null 2>&1; then
                mkdir -p ~/.config/tmux
                cp -a "$backup_path"/*.conf ~/.config/tmux/
            fi
            ;;
        starship)
            cp -a "$backup_path/starship.toml" ~/.config/starship.toml
            ;;
        *)
            echo "Unknown config: {{ config }}"
            exit 1
            ;;
    esac
    echo "✅ Restored successfully"

# Clean old backups (keep last N per config)
clean-backups keep="3":
    #!/usr/bin/env bash
    echo "Cleaning old backups (keeping last {{ keep }})..."
    for config_dir in ~/.config-backups/*/; do
        if [ -d "$config_dir" ]; then
            config=$(basename "$config_dir")
            count=$(ls -1 "$config_dir" 2>/dev/null | wc -l)
            if [ "$count" -gt "{{ keep }}" ]; then
                to_delete=$((count - {{ keep }}))
                echo "  $config: removing $to_delete old backup(s)"
                ls -1 "$config_dir" | head -n "$to_delete" | while read backup; do
                    rm -rf "$config_dir/$backup"
                done
            fi
        fi
    done
    echo "✅ Cleanup complete"

# Show help
help:
    @echo "Available commands:"
    @echo ""
    @echo "Installation:"
    @echo "  just install              # Full installation"
    @echo "  just install-fish         # Install Fish configuration"
    @echo "  just install-starship     # Install Starship prompt"
    @echo "  just install-tmux         # Install TMUX configuration"
    @echo "  just install-gitconfig    # Install git config (delta pager)"
    @echo "  just install-lazygit      # Install Lazygit config (auto-detects OS)"
    @echo "  just install-nvim         # Install Neovim configuration"
    @echo "  just install-spell        # Install Spell CLI tool"
    @echo "  just install-secrets      # Install API keys from .env"
    @echo ""
    @echo "Coding Agents:"
    @echo "  just install-coding-agents # Install all coding agent configs"
    @echo "  just install-claude        # Install Claude Code config"
    @echo "  just install-gemini        # Install Gemini CLI config"
    @echo "  just install-codex         # Install Codex CLI config"
    @echo "  just install-fish-private  # Setup private fish configs dir"
    @echo ""
    @echo "Preview & Diff:"
    @echo "  just check-changes        # Preview ALL changes (dry-run)"
    @echo "  just diff-config <name>   # Show diff for specific config"
    @echo "                            # (fish, git, tmux, starship, claude, gemini)"
    @echo ""
    @echo "Backup & Restore:"
    @echo "  just list-backups         # List all configuration backups"
    @echo "  just restore-backup <config> <timestamp>"
    @echo "  just clean-backups [keep] # Remove old backups (default: keep 3)"
    @echo ""
    @echo "Maintenance:"
    @echo "  just update               # Update all configurations"
    @echo "  just update-nvim          # Update Neovim plugins"
    @echo "  just check                # Check system setup"
    @echo "  just check-deps           # Check dependencies"
    @echo ""
    @echo "Environment Variables:"
    @echo "  DRY_RUN=1                 # Preview changes without applying"
    @echo "  BACKUP=0                  # Disable automatic backups"
    @echo ""
    @echo "Examples:"
    @echo "  DRY_RUN=1 just install-fish    # Preview Fish install"
    @echo "  BACKUP=0 just install-tmux     # Install without backup"

# Install Claude Code configuration
install-claude:
    #!/usr/bin/env bash
    echo "Installing Claude Code configuration..."
    mkdir -p ~/.claude
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  claude/settings.json -> ~/.claude/settings.json"
        echo "  claude/statusline.sh -> ~/.claude/statusline.sh"
        just show-diff claude/settings.json ~/.claude/settings.json
        just show-diff claude/statusline.sh ~/.claude/statusline.sh
    else
        just backup-file ~/.claude/settings.json claude
        just backup-file ~/.claude/statusline.sh claude
        cp {{ justfile_directory() }}/claude/settings.json ~/.claude/settings.json
        cp {{ justfile_directory() }}/claude/statusline.sh ~/.claude/statusline.sh
        chmod +x ~/.claude/statusline.sh
        echo "✅ Claude Code configuration installed"
    fi
    echo ""
    echo "See claude/mcp-servers.md to configure MCPs"
    echo "Skills are kept in ~/.claude/skills/ (private, not synced)"

# Install Gemini CLI configuration
install-gemini:
    #!/usr/bin/env bash
    echo "Installing Gemini CLI configuration..."
    mkdir -p ~/.gemini/extensions
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  gemini/settings.json -> ~/.gemini/settings.json"
        echo "  gemini/extension-enablement.json -> ~/.gemini/extensions/extension-enablement.json"
        just show-diff gemini/settings.json ~/.gemini/settings.json
    else
        if [ ! -f ~/.gemini/settings.json ]; then
            cp {{ justfile_directory() }}/gemini/settings.json ~/.gemini/settings.json
            echo "✅ Gemini settings installed"
        else
            echo "ℹ️  Gemini settings already exist, skipping"
        fi
        cp {{ justfile_directory() }}/gemini/extension-enablement.json ~/.gemini/extensions/extension-enablement.json 2>/dev/null || true
        echo "✅ Gemini extension config installed"
    fi
    echo ""
    echo "📖 Instalar extensiones:"
    echo "  gemini mcp add chrome-devtools -- npx chrome-devtools-mcp@latest"

# Setup private fish configurations directory
install-fish-private:
    #!/usr/bin/env bash
    echo "Setting up private fish configurations..."
    mkdir -p ~/.config/fish/conf.d/private
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would create: ~/.config/fish/conf.d/private/"
    else
        echo "✅ Private configs directory ready"
        echo ""
        echo "📁 Copia tus configs privadas a ~/.config/fish/conf.d/private/"
        echo "   Ejemplo: kavak.fish, proxyman.fish, local.fish"
        echo ""
        echo "📖 Ver fish/conf.d/private.fish.template para ejemplos"
    fi

# Install AIChat configuration
install-aichat:
    #!/usr/bin/env bash
    echo "Installing AIChat configuration..."
    mkdir -p ~/.config/aichat
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  aichat/config.yaml -> ~/.config/aichat/config.yaml"
        just show-diff aichat/config.yaml ~/.config/aichat/config.yaml
    else
        if [ ! -f ~/.config/aichat/config.yaml ]; then
            cp {{ justfile_directory() }}/aichat/config.yaml ~/.config/aichat/config.yaml
            echo "✅ AIChat configuration installed"
        else
            echo "ℹ️  AIChat config already exists, skipping"
        fi
    fi

# Install Codex CLI configuration
install-codex:
    #!/usr/bin/env bash
    echo "Installing Codex CLI configuration..."
    mkdir -p ~/.codex
    if [ -n "{{ dry_run }}" ]; then
        echo "[DRY-RUN] Would install:"
        echo "  codex/config.toml -> ~/.codex/config.toml"
        just show-diff codex/config.toml ~/.codex/config.toml
    else
        if [ ! -f ~/.codex/config.toml ]; then
            cp {{ justfile_directory() }}/codex/config.toml ~/.codex/config.toml
            echo "✅ Codex configuration installed"
        else
            echo "ℹ️  Codex config already exists"
            echo "    To update, manually merge or run:"
            echo "    just diff-config codex"
        fi
    fi
    echo ""
    echo "📖 Aliases disponibles (en fish):"
    echo "  cx   - codex (full-auto + search por defecto)"
    echo "  cxx  - codex exec (no interactivo)"
    echo "  cxr  - resume última sesión"
    echo "  cxw  - code review"

# Install JetBrains Mono Nerd Font (for terminal and nvim icons)
install-fonts:
    #!/usr/bin/env bash
    echo "Installing JetBrains Mono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    if [ -d "$FONT_DIR" ] && [ "$(ls -A $FONT_DIR 2>/dev/null)" ]; then
        echo "ℹ️  JetBrains Mono Nerd Font already installed"
    else
        mkdir -p "$FONT_DIR"
        cd "$FONT_DIR"
        echo "📥 Downloading from GitHub releases..."
        curl -sOL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
        tar -xf JetBrainsMono.tar.xz
        rm JetBrainsMono.tar.xz
        fc-cache -fv ~/.local/share/fonts > /dev/null 2>&1
        echo "✅ JetBrains Mono Nerd Font installed"
    fi

# Install Ghostty terminal configuration
install-ghostty:
    @echo "Installing Ghostty configuration..."
    @mkdir -p ~/.config
    @if [ -d ~/.config/ghostty ] && [ ! -L ~/.config/ghostty ]; then \
        echo "⚠️  Backing up existing Ghostty config..."; \
        mv ~/.config/ghostty ~/.config/ghostty.backup; \
    fi
    @echo "🔗 Creating symlink: $(pwd)/ghostty -> ~/.config/ghostty"
    @ln -sfn $(pwd)/ghostty ~/.config/ghostty
    @echo "✅ Ghostty configuration installed"

# Install all coding agents configurations
install-coding-agents: install-claude install-gemini install-aichat install-codex
    @echo "✅ All coding agents configured!"

# Default command
default: help
