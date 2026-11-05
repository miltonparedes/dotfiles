# Omarchy keeps bash as the login shell: its scripts, the uwsm session and the
# ~/.bashrc environment bootstrap all expect it, so we never chsh to fish.
# Ghostty launches fish directly, but remote sessions (SSH, rex blocks) start
# bash. This hands those interactive sessions over to fish once ~/.bashrc has
# set up the Omarchy environment, so it must be sourced at the END of ~/.bashrc.
#
# Stays in bash when:
#   - the shell is not interactive, or runs a command (ssh host cmd, scp,
#     rsync, bash -c, rex run --interactive -- cmd): BASH_EXECUTION_STRING is set
#   - the parent is fish, so typing `bash` inside fish gives you bash
#   - fish is not installed
# Escape hatch: `ssh host bash --norc`.
if [[ $- == *i* && -z ${BASH_EXECUTION_STRING:-} ]] \
  && [[ $(ps --no-headers --pid="$PPID" --format=comm 2>/dev/null) != fish ]] \
  && command -v fish >/dev/null 2>&1; then
  if shopt -q login_shell; then
    exec fish --login
  else
    exec fish
  fi
fi
