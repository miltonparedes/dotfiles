# dotfiles

A comprehensive dotfiles setup with Neovim configuration, CLI tools, and shell aliases for productive development environments.

## Quick Installation

Get up and running with a single command:

```bash
git clone https://github.com/USERNAME/dotfiles.git && cd dotfiles && ./install.sh
```

> **Note**: Replace `USERNAME` with your actual GitHub username

### Alternative with Just (Recommended)

If you prefer using `just` directly:

```bash
git clone https://github.com/USERNAME/dotfiles.git && cd dotfiles && just install
```

## Requirements

### System Dependencies

The installation script will automatically install these if missing:

- **git** - Version control
- **curl** - Download utilities
- **ripgrep** - Fast text search (for Neovim)

### macOS (via Homebrew)

For full functionality, Homebrew will install:

- **just** - Command runner
- **uv** - Python package manager
- **bat** - Enhanced cat with syntax highlighting
- **eza** - Modern ls replacement
- **fd** - Fast find alternative
- **gh** - GitHub CLI
- **glab** - GitLab CLI
- **zoxide** - Smart directory navigation
- **aichat** - AI-powered chat in terminal
- **lazygit** - Terminal UI for git
- **micro** - Terminal-based text editor
- **fzf** - Fuzzy finder
- **btop** - Resource monitor

### Python Dependencies

- **Python 3.10+**
- **python-dotenv** - Environment variable management
- **thefuzz** - Fuzzy string matching
- **rapidfuzz** - Fast string matching

### Linux Package Managers

Supported package managers:
- **apt** (Debian/Ubuntu)
- **yum** (CentOS/RHEL)
- **dnf** (Fedora)
- **pacman** (Arch)
- **zypper** (openSUSE)

## Installation Methods

### Full Installation (Recommended)

```bash
# Clone and install everything
git clone https://github.com/USERNAME/dotfiles.git
cd dotfiles
./install.sh
```

### Alternative: Using Just

```bash
# If you have just installed
just install
```

### Neovim Only

For just the Neovim configuration:

```bash
# Using install.sh wrapper
./install.sh --nvim-only

# Or directly with just
just install-nvim
```

## Just Commands

This project uses `just` as the primary task runner for consistency across all configurations. Here are the most useful commands:

### Installation Commands

```bash
just install               # Full installation (CLI tools + Neovim + shell config)
just install-nvim          # Install only Neovim configuration
just install-nvim-deps     # Install Neovim dependencies (git, curl, ripgrep, neovim)
just install-os-config     # Install OS-specific configurations
just install-spell         # Install Spell CLI tool
```

### Neovim Management

```bash
just install-nvim          # Install/reinstall Neovim configuration
just update-nvim           # Update Neovim plugins
just backup-nvim-config    # Backup existing Neovim configuration
just check-nvim-deps       # Check if Neovim dependencies are installed
```

### Other Commands

```bash
just --list                # Show all available commands
just --help                # Show just help
```

### Development Containers Only

For containerized development environments:

```bash
# Optional: Set OpenAI API key for aichat
export OPENAI_API_KEY=your-api-key-here

# Install devcontainer tools
curl -sSL https://raw.githubusercontent.com/USERNAME/dotfiles/main/devcontainers/install.sh | bash
```

## Plugin Management

### Neovim Plugins (Lazy.nvim)

Plugins are automatically installed on first run. To update plugins:

```bash
# Update all plugins using just (recommended)
just update-nvim

# Or using install.sh wrapper
./install.sh --update

# Or from within Neovim
:Lazy sync
```

#### Manual Plugin Management

```bash
# Open Lazy plugin manager
nvim +Lazy

# Available commands in Lazy:
# - `I` - Install missing plugins
# - `U` - Update plugins
# - `S` - Sync (clean + update)
# - `C` - Clean unused plugins
# - `R` - Restore plugins from lockfile
```

### CLI Tools Updates

```bash
# Update Homebrew packages (macOS)
brew update && brew upgrade

# Update Python packages
uv pip sync requirements.txt

# Update specific tools
brew upgrade just uv aichat lazygit
```

## Configuration

### Environment Variables & Secrets

Create a `.env` file from the sample template:

```bash
cp sample.env .env
```

Then edit `.env` with your specific values:

```bash
# Remote development settings
REMOTE_HOST=your-host.local
REMOTE_USER=your-username
REMOTE_WORKSPACE=/path/to/remote/workspace
LOCAL_WORKSPACE=/path/to/local/workspace

# AI Chat Configuration
OPENAI_API_KEY=your-openai-api-key
```

### Overriding Local Secrets

To override secrets locally without affecting the repository:

1. **Never commit `.env` files** - they're gitignored by default
2. **Use environment variables**:
   ```bash
   export OPENAI_API_KEY="your-secret-key"
   export REMOTE_HOST="your-host"
   ```
3. **Use shell-specific configs**:
   ```bash
   # In ~/.zshrc (macOS) or ~/.bashrc (Linux)
   export OPENAI_API_KEY="your-secret-key"
   ```
4. **Use system keychain** (macOS):
   ```bash
   # Store in keychain
   security add-generic-password -a $(whoami) -s "openai-api-key" -w "your-key"
   
   # Retrieve in scripts
   OPENAI_API_KEY=$(security find-generic-password -a $(whoami) -s "openai-api-key" -w)
   ```

### Shell Configuration

The installer automatically configures shell aliases and functions:

- **macOS**: Uses zsh with configs in `~/.zshrc.d/`
- **Linux**: Uses bash with configs in `~/.bashrc.d/`

### Git Configuration

Lazygit configuration is automatically installed:
- **macOS**: `~/Library/Application Support/lazygit/config.yml`
- **Linux**: `~/.config/lazygit/config.yml`

## Troubleshooting

### Common Issues

1. **Permission denied on install.sh**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

2. **Missing Homebrew (macOS)**:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Neovim plugins not loading**:
   ```bash
   # Remove plugin data and reinstall
   rm -rf ~/.local/share/nvim
   ./install.sh
   ```

4. **Python dependencies issues**:
   ```bash
   # Reinstall with uv
   uv pip install -r requirements.txt --force-reinstall
   ```

### Getting Help

```bash
# Show install script help
./install.sh --help

# Check installation status
nvim --version
just --version
```

## What Gets Installed

- **Neovim Configuration**: Complete IDE-like setup with LSP, autocomplete, and plugins
- **Shell Aliases**: Productivity shortcuts for common commands
- **Git Tools**: Lazygit for terminal-based git operations
- **CLI Utilities**: Modern replacements for common Unix tools
- **AI Integration**: Terminal-based AI chat and assistance
- **Development Tools**: Language servers, formatters, and linters

## Contributing

Feel free to fork this repository and customize it for your needs. The configuration is modular and easy to extend.
