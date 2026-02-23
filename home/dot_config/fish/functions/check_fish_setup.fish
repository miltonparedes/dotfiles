function check_fish_setup --description 'Verify Fish shell installation and configuration'
    # Colors
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l blue (set_color blue)
    set -l normal (set_color normal)

    echo -n -s $blue "=== Fish Shell Setup Verification ===" $normal
    echo ""
    echo ""

    # Check Fish version
    echo -n "Fish Shell: "
    if command -q fish
        set -l version (fish --version | string replace -r "fish, version " "")
        echo -n -s $green "✓ Installed" $normal " (v$version)"
    else
        echo -n -s $red "✗ Not installed" $normal
    end
    echo ""

    # Check essential tools
    set -l tools "zoxide" "fzf" "eza" "bat" "fd" "rg" "nvim" "git" "just"

    echo ""
    echo "Essential Tools:"
    for tool in $tools
        echo -n "  $tool: "
        if command -q $tool
            echo -n -s $green "✓" $normal
        else
            echo -n -s $red "✗" $normal
            switch $tool
                case "zoxide"
                    echo -n " (smart cd - install with: brew install zoxide)"
                case "fzf"
                    echo -n " (fuzzy finder - install with: brew install fzf)"
                case "eza"
                    echo -n " (better ls - install with: brew install eza)"
                case "bat"
                    echo -n " (better cat - install with: brew install bat)"
                case "fd"
                    echo -n " (better find - install with: brew install fd)"
                case "rg"
                    echo -n " (ripgrep - install with: brew install ripgrep)"
                case "nvim"
                    echo -n " (neovim - install with: brew install neovim)"
                case "just"
                    echo -n " (command runner - install with: brew install just)"
            end
        end
        echo ""
    end

    # Check configuration files
    echo ""
    echo "Configuration Files:"

    set -l config_files \
        "$HOME/.config/fish/config.fish" \
        "$HOME/.config/fish/conf.d/aliases.fish" \
        "$HOME/.config/fish/conf.d/integrations.fish" \
        "$HOME/.config/fish/functions/fish_prompt.fish"

    for file in $config_files
        echo -n "  "(basename (dirname $file))"/"(basename $file)": "
        if test -f $file
            echo -n -s $green "✓" $normal
        else
            echo -n -s $red "✗" $normal
        end
        echo ""
    end

    # Check environment
    echo ""
    echo "Environment:"
    echo -n "  Current Shell: "
    if string match -q "*fish*" $SHELL
        echo -n -s $green "Fish is default" $normal
    else
        echo -n -s $yellow "Not Fish (current: $SHELL)" $normal
        echo ""
        echo -n -s "  " $yellow "To make Fish your default shell, run: chsh -s "(which fish) $normal
    end
    echo ""

    # SSH check
    if set -q SSH_CLIENT
        or set -q SSH_TTY
        echo ""
        echo -n -s $blue "Note: You're in an SSH session" $normal
        echo ""
    end

    # Summary
    echo ""
    echo -n -s $blue "=== Summary ===" $normal
    echo ""

    # Count missing tools
    set -l missing_count 0
    for tool in $tools
        if not command -q $tool
            set missing_count (math $missing_count + 1)
        end
    end

    if test $missing_count -eq 0
        echo -n -s $green "✓ All tools are installed!" $normal
    else
        echo -n -s $yellow "⚠ $missing_count tool(s) missing. Install with: brew bundle --file cli.Brewfile" $normal
    end
    echo ""

    # Final recommendation
    echo ""
    echo "Quick commands:"
    echo "  just apply            # Apply all configurations (chezmoi)"
    echo "  just switch-to-fish   # Switch to Fish shell"
    echo "  lsrepo               # List workspace aliases"
    echo "  reload               # Reload Fish configuration"
end
