# Spell - My enchanted command-line companion
# Cast powerful incantations to streamline my development workflow and conjure productivity
help:
   just --list

# Update dotfiles
update-dotfiles:
    @echo "Casting the dotfile renewal spell..."
    # Commands to update your dotfiles

# Sync with workstation
sync-workstation:
    @echo "Invoking the workstation synchronization ritual..."
    # Commands to sync with your workstation via SSH

# Switch between configurations
switch-config profile:
    @echo "Transmuting configuration to: {{profile}}"
    # Commands to switch between different configurations

@import "langfuse.just"
