#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Flags
UPDATE_FLAG=false
NVIM_ONLY=false
FISH_ONLY=false
DRY_RUN_FLAG=false
NO_BACKUP_FLAG=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if just is installed
check_just() {
    if ! command -v just >/dev/null 2>&1; then
        print_error "'just' is required but not installed"
        print_status "Installing 'just'..."
        
        if [[ "$(uname)" == "Darwin" ]]; then
            if command -v brew >/dev/null 2>&1; then
                brew install just
            else
                print_error "Homebrew is required to install 'just' on macOS"
                print_status "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                exit 1
            fi
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y just
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y just
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm just
        else
            print_error "Unable to install 'just' automatically"
            print_status "Please install 'just' manually: https://github.com/casey/just#installation"
            exit 1
        fi
        
        print_success "'just' installed successfully"
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --update      Update Neovim plugins (equivalent to 'just update-nvim')"
    echo "  --nvim-only   Install only Neovim configuration (equivalent to 'just install-nvim')"
    echo "  --fish-only   Install only Fish shell configuration (equivalent to 'just install-fish')"
    echo "  --dry-run     Preview changes without applying (sets DRY_RUN=1)"
    echo "  --no-backup   Disable automatic backups (sets BACKUP=0)"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     # Full installation"
    echo "  $0 --dry-run           # Preview all changes without applying"
    echo "  $0 --fish-only         # Install only Fish shell"
    echo "  $0 --dry-run --fish-only  # Preview Fish changes only"
    echo ""
    echo "Available just commands:"
    echo "  just install        # Full installation"
    echo "  just check-changes  # Preview ALL changes (dry-run)"
    echo "  just diff-config X  # Show diff for specific config"
    echo "  just list-backups   # List configuration backups"
    echo "  just --list         # Show all available commands"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_FLAG=true
            shift
            ;;
        --nvim-only)
            NVIM_ONLY=true
            shift
            ;;
        --fish-only)
            FISH_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN_FLAG=true
            shift
            ;;
        --no-backup)
            NO_BACKUP_FLAG=true
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

# Main execution
main() {
    print_status "Starting dotfiles installation..."

    # Check if just is installed
    check_just

    # Change to script directory
    cd "$SCRIPT_DIR"

    # Set environment variables based on flags
    if [[ "$DRY_RUN_FLAG" == true ]]; then
        export DRY_RUN=1
        print_warning "DRY-RUN mode: No changes will be made"
    fi

    if [[ "$NO_BACKUP_FLAG" == true ]]; then
        export BACKUP=0
        print_warning "Backups disabled"
    fi

    # Detect shell and show recommendation
    if command -v fish >/dev/null 2>&1; then
        print_status "Fish shell detected! Your configuration will include Fish support."
    else
        if [[ "$(uname)" == "Darwin" ]]; then
            print_warning "Fish not detected. Install with: brew install fish"
        else
            print_warning "Fish not detected. Install with: sudo dnf install fish (Fedora/Bluefin)"
        fi
    fi

    # Execute based on flags
    if [[ "$UPDATE_FLAG" == true ]]; then
        print_status "Updating Neovim configuration..."
        just update-nvim
    elif [[ "$NVIM_ONLY" == true ]]; then
        print_status "Installing Neovim configuration only..."
        just install-nvim
    elif [[ "$FISH_ONLY" == true ]]; then
        print_status "Installing Fish shell configuration only..."
        just install-fish
    else
        print_status "Running full installation..."
        just install
    fi

    if [[ "$DRY_RUN_FLAG" != true ]]; then
        print_success "Installation completed!"
    else
        print_success "Dry-run completed! No changes were made."
    fi
    print_status "Available commands:"
    print_status "  just check-changes   # Preview all changes"
    print_status "  just list-backups    # List configuration backups"
    print_status "  just --list          # Show all available commands"

    if command -v fish >/dev/null 2>&1; then
        print_status "Start Fish shell with: fish"
    fi
}

# Run main function
main "$@"
