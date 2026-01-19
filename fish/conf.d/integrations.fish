# Fish Shell Integrations
# Configure third-party tool integrations

# FZF - Fuzzy Finder
if command -q fzf
    # Set FZF default options
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --inline-info'
    
    # Use fd for FZF if available (faster than find)
    if command -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end
    
    # Load FZF key bindings for fish
    if test -f /opt/homebrew/opt/fzf/shell/key-bindings.fish
        source /opt/homebrew/opt/fzf/shell/key-bindings.fish
    else if test -f /usr/local/opt/fzf/shell/key-bindings.fish
        source /usr/local/opt/fzf/shell/key-bindings.fish
    else if test -f /usr/share/fzf/shell/key-bindings.fish
        source /usr/share/fzf/shell/key-bindings.fish
    else if test -f ~/.fzf/shell/key-bindings.fish
        source ~/.fzf/shell/key-bindings.fish
    end
    
    # Enable FZF completion
    fzf --fish | source
end

# Zoxide - Smarter cd command
if command -q zoxide
    zoxide init fish | source
    
    # Additional zoxide aliases
    alias zi='zoxide query -i'  # Interactive selection
    alias zq='zoxide query'      # Query database
    alias za='zoxide add'        # Add directory manually
end

# Starship Prompt - Modern cross-shell prompt
if command -q starship
    starship init fish | source
end

# direnv - Environment variable management
if command -q direnv
    direnv hook fish | source
end

# asdf - Version manager
if test -f ~/.asdf/asdf.fish
    source ~/.asdf/asdf.fish
else if test -f /opt/homebrew/opt/asdf/libexec/asdf.fish
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
else if test -f /usr/local/opt/asdf/libexec/asdf.fish
    source /usr/local/opt/asdf/libexec/asdf.fish
end

# Homebrew (macOS)
if test (uname) = "Darwin"
    # Set up Homebrew environment
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    end
end

# Cargo/Rust
if test -d ~/.cargo/bin
    fish_add_path ~/.cargo/bin
end

# Go
if command -q go
    set -gx GOPATH ~/go
    fish_add_path $GOPATH/bin
end

# Node Version Manager (nvm) - Fish version
if test -f ~/.config/fish/functions/nvm.fish
    source ~/.config/fish/functions/nvm.fish
end

# pyenv
if command -q pyenv
    pyenv init - | source
end

# rbenv
if command -q rbenv
    rbenv init - | source
end

# bat (better cat) configuration
if command -q bat
    set -gx BAT_THEME "OneHalfDark"
    alias cat='bat --style=plain'
    alias catn='bat --style=numbers'
end

# ripgrep configuration
if command -q rg
    set -gx RIPGREP_CONFIG_PATH ~/.config/ripgrep/config
end

# SSH Agent (if not already running)
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
end

# Atuin - Shell history search
if command -q atuin
    atuin init fish | source
end

# Kiro IDE integration
if test "$TERM_PROGRAM" = "kiro"
    and command -q kiro
    . (kiro --locate-shell-integration-path fish)
end