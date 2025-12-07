# Dotfiles

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/Workspaces/M/dotfiles
cd ~/Workspaces/M/dotfiles

# Full installation
./install.sh
# or
just install
```

## ✨ Features

- **Fish Shell**: Modern, user-friendly shell with autosuggestions and syntax highlighting
- **Starship**: Blazing-fast, customizable prompt that works across shells
- **TMUX**: Terminal multiplexer with custom theme and keybindings
- **Neovim**: Fully configured with LSP, Treesitter, and modern plugins
- **Cross-platform**: Works seamlessly on macOS and Bluefin/Fedora
- **SSH-ready**: Optimized for remote development workflows

## 🐟 Fish Shell

This configuration uses **Fish** as the primary shell, replacing bash/zsh with a more modern alternative:

- **Autosuggestions**: Type faster with intelligent command suggestions
- **Syntax highlighting**: See errors before running commands
- **Smart abbreviations**: Expand shortcuts inline for easy editing
- **No configuration needed**: Works great out of the box

### Make Fish your default shell

```bash
# Add Fish to valid shells
echo $(which fish) | sudo tee -a /etc/shells

# Change default shell
chsh -s $(which fish)

# Or use the helper command
just switch-to-fish
```

## 🌟 Starship Prompt

Starship provides a minimal, blazing-fast, and infinitely customizable prompt:

- Git status and branch information
- Command duration for long-running processes
- Python virtual environment detection
- SSH session indicators
- Consistent across Fish, Bash, and Zsh

## 🖥️ TMUX Configuration

Enhanced TMUX setup with:

- **Custom prefix**: `Ctrl-a` instead of `Ctrl-b`
- **Mouse support**: Click to switch panes and windows
- **Theme**: tmux-power with network speed indicators
- **Smart session management**: Project-specific sessions
- **1-indexed**: Windows and panes start at 1

### TMUX Shortcuts

```bash
ta <session>   # Attach to session
ts <name>      # New session
tl             # List sessions
tp             # Project-specific session (auto-named)
```

## 📦 Installation

### Prerequisites

The installer will check for these automatically:

- **macOS**: Homebrew
- **Fedora/Bluefin**: DNF package manager
- **Git**: For cloning repositories

### Full Installation

```bash
# Clone and install everything
git clone https://github.com/USERNAME/dotfiles.git ~/Workspaces/M/dotfiles
cd ~/Workspaces/M/dotfiles

# Run full installation
just install
```

### Component Installation

```bash
just install-fish         # Fish shell configuration only
just install-starship     # Starship prompt only
just install-tmux        # TMUX configuration only
just install-nvim        # Neovim configuration only
just install-spell       # Spell CLI tool
```

### Update Components

```bash
just update              # Update all configurations
just update-nvim         # Update Neovim plugins only
```

## 🛠️ CLI Tools

Essential CLI tools installed via Homebrew:

- **just**: Task runner (like make, but better)
- **uv**: Fast Python package manager
- **bat**: cat with syntax highlighting
- **eza**: Modern ls replacement
- **fd**: User-friendly find
- **ripgrep**: Blazing fast grep
- **fzf**: Fuzzy finder
- **zoxide**: Smarter cd command
- **lazygit**: Terminal UI for git
- **gh**: GitHub CLI
- **glab**: GitLab CLI
- **btop**: Resource monitor
- **aichat**: AI chat in terminal

Install all with:

```bash
just install-brew-essential-cli-packages
```

## ⚙️ Configuration Files

```
dotfiles/
├── fish/                  # Fish shell configuration
│   ├── config.fish       # Main config
│   ├── conf.d/          # Auto-loaded configs
│   │   ├── aliases.fish
│   │   ├── abbreviations.fish
│   │   ├── integrations.fish
│   │   └── tmux.fish
│   └── functions/       # Custom functions
├── starship.toml        # Starship prompt config
├── tmux.conf            # TMUX configuration
├── nvim/                # Neovim configuration
├── cli.Brewfile         # Homebrew packages
└── Justfile            # Task definitions
```

## 🔍 Verification

Check your setup:

```bash
# Check all dependencies
just check

# Fish-specific verification
fish -c "check_fish_setup"
```

## 🚀 Workflow Tips

### Fish Productivity

1. **Abbreviations**: Type `gaa` and space to expand to `git add --all`
2. **Directory navigation**: Use `z` to jump to frecent directories
3. **Fuzzy history**: Press `Ctrl+R` for interactive history search
4. **Smart completions**: Press `Tab` for context-aware suggestions

### TMUX Workflow

1. **Project sessions**: Run `tp` in any project directory
2. **Split panes**: `Ctrl-a |` (vertical) or `Ctrl-a -` (horizontal)
3. **Navigate panes**: Click with mouse or `Ctrl-a` + arrow keys
4. **Zoom pane**: `Ctrl-a z` to focus/unfocus current pane

### Remote Development

Perfect for SSH workflows:

```bash
# On remote server
just install

# Start TMUX session
tmux new -s dev

# Your complete environment is ready!
```

## 🔧 Customization

### Add Custom Aliases

Edit `fish/conf.d/aliases.fish`:

```fish
alias mycommand='actual-command --with-options'
```

### Modify Starship Prompt

Edit `starship.toml` to customize your prompt.

### TMUX Keybindings

Edit `tmux.conf` to add custom keybindings.

## 📚 Documentation

- [Fish Documentation](https://fishshell.com/docs/current/)
- [Starship Documentation](https://starship.rs/)
- [TMUX Documentation](https://github.com/tmux/tmux/wiki)
- [Just Documentation](https://github.com/casey/just)

## 🐛 Troubleshooting

### Fish not recognized as valid shell

```bash
echo $(which fish) | sudo tee -a /etc/shells
```

### TMUX plugins not loading

```bash
# Install TPM (TMUX Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# In TMUX, press Ctrl-a I to install plugins
```

### Starship not showing

```bash
# Verify Starship is installed
starship --version

# Reinstall Fish config
just install-fish
```

### Commands not found

```bash
# Ensure Homebrew packages are installed
just install-brew-essential-cli-packages

# Reload Fish configuration
source ~/.config/fish/config.fish
```

## 📝 License

MIT - Feel free to use and modify for your needs!
