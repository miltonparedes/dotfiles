#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Homebrew is available
ensure_brew() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi

    if [[ "$(uname)" == "Darwin" ]]; then
        print_error "Homebrew is required. Install with:"
        echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    elif [[ "$(uname)" == "Linux" ]]; then
        if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        else
            print_error "Homebrew is required. Install with:"
            echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
            exit 1
        fi
    fi
}

# Install chezmoi if not present
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        print_success "chezmoi is already installed"
        return 0
    fi

    print_status "Installing chezmoi..."
    ensure_brew
    brew install chezmoi
    print_success "chezmoi installed"
}

# Install just if not present
install_just() {
    if command -v just >/dev/null 2>&1; then
        return 0
    fi

    print_status "Installing just..."
    ensure_brew
    brew install just
    print_success "just installed"
}

# Create symlink for chezmoi source
setup_chezmoi_source() {
    local chezmoi_dir="$HOME/.local/share/chezmoi"
    if [[ -L "$chezmoi_dir" ]] && [[ "$(readlink "$chezmoi_dir")" == "$SCRIPT_DIR" ]]; then
        print_success "chezmoi source symlink already exists"
        return 0
    fi

    if [[ -e "$chezmoi_dir" ]] && [[ ! -L "$chezmoi_dir" ]]; then
        print_error "$chezmoi_dir exists and is not a symlink"
        print_status "Move/remove it and rerun bootstrap"
        exit 1
    fi

    print_status "Setting up chezmoi source symlink..."
    mkdir -p "$(dirname "$chezmoi_dir")"
    ln -sfn "$SCRIPT_DIR" "$chezmoi_dir"
    print_success "Symlinked $SCRIPT_DIR -> $chezmoi_dir"
}

# Initialize chezmoi
init_chezmoi() {
    print_status "Initializing chezmoi..."
    chezmoi init
    print_success "chezmoi initialized"
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Bootstrap dotfiles with chezmoi."
    echo ""
    echo "Options:"
    echo "  --apply     Run chezmoi apply after init"
    echo "  -h, --help  Show this help message"
    echo ""
    echo "After bootstrap, use:"
    echo "  chezmoi apply -v      # Apply all configs"
    echo "  chezmoi diff          # Preview changes"
    echo "  just install          # Full install (brew + chezmoi + mux + nvim)"
}

APPLY_FLAG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --apply)
            APPLY_FLAG=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

main() {
    print_status "Bootstrapping dotfiles..."

    install_chezmoi
    install_just
    setup_chezmoi_source
    init_chezmoi

    if [[ "$APPLY_FLAG" == true ]]; then
        print_status "Applying configurations..."
        chezmoi apply -v
        print_success "Configurations applied!"
    fi

    print_success "Bootstrap complete!"
    echo ""
    print_status "Next steps:"
    echo "  chezmoi apply -v          # Apply all configs"
    echo "  chezmoi diff              # Preview changes"
    echo "  just install              # Full install (brew + chezmoi + mux + nvim)"

    if command -v fish >/dev/null 2>&1; then
        print_status "Fish shell detected. Start with: fish"
    else
        print_warning "Fish not detected. Install with: brew install fish"
    fi
}

main "$@"
