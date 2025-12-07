# Fish Shell Configuration
# Main configuration file for fish shell

# Set environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# Set fish greeting (empty to disable)
set -g fish_greeting

# Configure PATH
fish_add_path /usr/local/bin
fish_add_path /opt/homebrew/bin

# Source all configuration files in conf.d/
# Fish automatically does this, but we ensure the path is correct
set -g fish_config_dir ~/.config/fish

# Colors for ls command (if using GNU ls)
set -gx LSCOLORS "ExGxBxDxCxEgEdxbxgxcxd"

# Set language environment
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# History configuration
set -g fish_history_size 10000

# Vi mode configuration (optional, comment out if you prefer emacs mode)
# fish_vi_key_bindings

# Load custom functions and completions
# These are automatically loaded from functions/ and completions/ directories