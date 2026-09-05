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
```

### Coding agents

```bash
just install-claude       # Claude Code
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
codex/                     # Codex CLI config
code/                      # VSCode settings
zed/                       # Zed editor settings
cli.Brewfile               # Homebrew packages
```

## Fish shell

Set as default shell:

```bash
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### Zed Remote fish handoff

Zed remote terminals can start the platform login shell before applying the
configured fish shell. These dotfiles set `terminal.env.ZED_WANTS_FISH=1` in Zed
and install a shared hook for zsh and bash:

- macOS/zsh: `.zshenv` sources `~/.config/shell/zed-fish-shell-hook.sh`.
- Linux/bash: `.bashrc` and `.bash_profile` source the same hook, and Zed sets
  `BASH_ENV=${HOME}/.config/shell/zed-fish-shell-hook.sh` for non-interactive
  bash launches.

The hook uses `ZED_FISH_LAUNCHED` to avoid loops and falls back to common fish
paths on macOS and Linux when `fish` is not already on `PATH`.

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

## Herdr

Managed by chezmoi at `home/dot_config/herdr/config.toml.tmpl` (Herdr 0.8.2+).
Only configuration is tracked; sessions, logs, sockets and local plugins stay local.
Fish is selected per platform: Homebrew on macOS, `/usr/bin/fish` on Linux.
New terminals follow the current pane directory; existing shells keep running.

Preview, apply and reload just this configuration:

```bash
chezmoi diff ~/.config/herdr/config.toml
chezmoi apply ~/.config/herdr/config.toml
herdr config check
herdr server reload-config
```

Gruvbox separators use `surface_dim = "#928374"`, matching the scrollbar's
`overlay0`, instead of the invisible `#282828` default. This follows the approach
used on `box` (`#665c54` separators), with more contrast locally. The active tab
uses muted ochre `#b39a62`; Herdr shares this accent with focused pane borders.
Internal splitters stay visible without an outside frame or gaps.

Prefix: backtick, matching tmux. Press it twice to type a literal backtick.
Herdr supports one prefix, so tmux's secondary `Ctrl-a` is not replicated.

| Shortcut | Action |
| --- | --- |
| Prefix + `h/j/k/l` or arrows | Focus pane |
| Prefix + `H/J/K/L` | Resize pane |
| Prefix + `\|` | Split side by side |
| Prefix + `-` or `\` | Split top/bottom |
| Prefix + `f` | Zoom pane |
| Prefix + `c`, `1..9` | New tab, select tab |
| `Ctrl-Tab` / `Ctrl-Shift-Tab` | Next / previous tab |
| Prefix + `o` / `w`, or `Alt-s` | Workspace picker |
| Prefix + `e`, or `Alt-k` | Native navigation (Goto) |
| Prefix + `W` | Open worktree |
| Prefix + `Alt-w` | Rename workspace |
| Prefix + `A` | Open notification target |
| Prefix + `Alt-1..9` | Focus indexed agent |
| Prefix + `p`, or `Alt-j` | Fish popup; `exit` closes it |
| Prefix + `g` / `v` | Lazygit / Neovim popup |
| Prefix + `z` | Open current directory in Zed |
| Prefix + `r` / `R` | Reload config / resize mode |
| Prefix + `q` / `?` | Detach / active shortcut help |

These use native Herdr navigation instead of invoking kitmux, which controls
tmux sessions. Alt and Ctrl-Tab shortcuts depend on the outer terminal forwarding
them; prefix shortcuts remain available (use Prefix + `1..9` to select a tab).
The settings above apply locally; remote servers need their own configuration.

Reference: [Herdr configuration](https://herdr.dev/docs/configuration/).

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
