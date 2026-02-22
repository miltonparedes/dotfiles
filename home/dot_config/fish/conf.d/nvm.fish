set -gx NVM_DIR $HOME/.nvm
set -gx NVM_HOMEBREW /opt/homebrew/opt/nvm
mkdir -p $NVM_DIR

if test -f "$NVM_HOMEBREW/nvm.sh"; and type -q bass
  bass source "$NVM_HOMEBREW/nvm.sh" --no-use ';' nvm use --silent default
end
