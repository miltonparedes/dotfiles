# Fish Shell Color Theme Configuration
# One Dark inspired color scheme

# Syntax Highlighting Colors
set -g fish_color_normal normal
set -g fish_color_command blue
set -g fish_color_keyword blue
set -g fish_color_quote green
set -g fish_color_redirection cyan
set -g fish_color_end cyan
set -g fish_color_error red
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_selection --background=brblack
set -g fish_color_search_match --background=yellow
set -g fish_color_operator cyan
set -g fish_color_escape yellow
set -g fish_color_autosuggestion brblack
set -g fish_color_cancel red

# Completion Pager Colors
set -g fish_pager_color_completion normal
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix blue
set -g fish_pager_color_progress brwhite --background=cyan

# Enable 24-bit true color support if available
if test "$TERM" = "xterm-256color"
    or test "$TERM" = "screen-256color"
    or test "$TERM" = "tmux-256color"
    set -g fish_term24bit 1
end

# Directory colors for ls/eza
set -gx LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Man page colors
set -gx LESS_TERMCAP_mb (printf "\033[01;31m")     # begin blinking
set -gx LESS_TERMCAP_md (printf "\033[01;31m")     # begin bold
set -gx LESS_TERMCAP_me (printf "\033[0m")         # end mode
set -gx LESS_TERMCAP_se (printf "\033[0m")         # end standout-mode
set -gx LESS_TERMCAP_so (printf "\033[01;44;33m")  # begin standout-mode - info box
set -gx LESS_TERMCAP_ue (printf "\033[0m")         # end underline
set -gx LESS_TERMCAP_us (printf "\033[01;32m")     # begin underline