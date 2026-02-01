# Dotfiles

Configuration for Fish, Starship, TMUX, Neovim and development tools.

Works on macOS (Homebrew) and Fedora/Bluefin (DNF).

## Installation

```bash
git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script installs `just` if missing and runs the full installation.

### Per-component installation

```bash
just install-fish         # Fish shell
just install-starship     # Prompt
just install-tmux         # Terminal multiplexer
just install-nvim         # Neovim (symlink)
just install-gitconfig    # Git with delta
just install-lazygit      # Lazygit
just install-spell        # Spell CLI
```

### Coding agents

```bash
just install-claude       # Claude Code
just install-gemini       # Gemini CLI
just install-codex        # Codex CLI
just install-aichat       # AIChat
just install-coding-agents # All
```

### Preview and backups

```bash
just check-changes              # Preview changes without applying
DRY_RUN=1 just install-fish     # Dry-run a component
just diff-config tmux           # Diff specific config
just list-backups               # List backups
just restore-backup fish <ts>   # Restore backup
```

Backups are created automatically in `~/.config-backups/`.

## Structure

```
fish/
  config.fish              # Main config
  conf.d/                  # Auto-loaded
    aliases.fish
    abbreviations.fish
    integrations.fish      # fzf, zoxide, starship
    tmux.fish
    workspaces.fish
  functions/               # Custom functions

nvim/                      # LazyVim config (symlink to ~/.config/nvim)
tmux.conf                  # TMUX config
starship.toml              # Prompt config
git/config                 # Git config with delta
lazygit/                   # Lazygit config
aichat/                    # AIChat config
claude/                    # Claude Code settings
gemini/                    # Gemini CLI settings
codex/                     # Codex CLI config
spell/                     # Spell CLI (justfiles)
cli.Brewfile               # Homebrew packages
```

## Fish shell

Set as default shell:

```bash
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

Useful abbreviations (expand with space):
- `g` -> `git`
- `ga` -> `git add`
- `gc` -> `git commit`
- `gp` -> `git push`

## TMUX

Prefix: `Ctrl-a`

Main shortcuts:
- `Ctrl-a |` vertical split
- `Ctrl-a -` horizontal split
- `Ctrl-a z` zoom pane
- Click to switch panes

Fish functions:
- `ta <session>` attach
- `ts <name>` new session
- `tl` list sessions

## CLI tools

See `cli.Brewfile` for full list. Install with:

```bash
just install-brew-essential-cli-packages
```

Main tools: bat, eza, fd, ripgrep, fzf, zoxide, lazygit, gh, btop.

## Verify installation

```bash
just check           # Check dependencies and configs
just check-deps      # Dependencies only
```

## Update

```bash
just update          # Everything
just update-nvim     # Neovim plugins only
```
