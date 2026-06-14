# Zed remote terminals sometimes start the login shell even when the configured
# shell is fish. zsh reads .zshenv for every shell; bash reads BASH_ENV for
# non-interactive shells and .bashrc/.bash_profile for interactive shells.
# Only replace the shell for real interactive terminals. Non-interactive shells
# such as `zsh -lc <command>` must keep executing their `-c` payload; otherwise
# agent command runners report success after Fish startup without running the
# requested command.
case "$-" in
  *i*) _zed_shell_is_interactive=1 ;;
  *) _zed_shell_is_interactive=0 ;;
esac

if [ "$_zed_shell_is_interactive" = "1" ] && [ -z "${ZSH_EXECUTION_STRING:-}${BASH_EXECUTION_STRING:-}" ] && [ "${ZED_WANTS_FISH:-}" = "1" ] && [ -z "${ZED_FISH_LAUNCHED:-}" ]; then
  export ZED_FISH_LAUNCHED=1
  unset ZED_WANTS_FISH

  if command -v fish >/dev/null 2>&1; then
    exec fish
  elif [ -x /opt/homebrew/bin/fish ]; then
    exec /opt/homebrew/bin/fish
  elif [ -x /usr/local/bin/fish ]; then
    exec /usr/local/bin/fish
  elif [ -x /usr/bin/fish ]; then
    exec /usr/bin/fish
  elif [ -x /home/linuxbrew/.linuxbrew/bin/fish ]; then
    exec /home/linuxbrew/.linuxbrew/bin/fish
  fi
fi

unset _zed_shell_is_interactive
