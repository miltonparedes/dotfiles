#!/bin/bash
# Install base16.yazi flavor if not present
if command -v yazi &>/dev/null; then
    flavor_dir="$HOME/.config/yazi/flavors/base16.yazi"
    if [ ! -d "$flavor_dir" ]; then
        mkdir -p "$HOME/.config/yazi/flavors"
        git clone --depth 1 https://github.com/matt-dong-123/base16.yazi.git "$flavor_dir"
    fi
fi
