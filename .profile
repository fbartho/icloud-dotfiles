# Initialize my "xenv" language runtime managers if installed
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Additional PATH configuration

## My own scripts
PATH="$HOME/.bin:$PATH"
PATH="/usr/local/sbin:$PATH"
PATH="/usr/local/share/npm/bin:$PATH"

# Bash settings

## stickier .bash_history
shopt -s histappend

## Set up tab-completion (requires `brew install bash-completion`)
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  source $(brew --prefix)/etc/bash_completion
fi

## Setup yarn tab-completion
[ -f ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash ] && . ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash


# Other Customization

## Editor registration for git, etc
export EDITOR=emacs

export CODE_DIR="$HOME/Code"

## Reference the location of iCloud Drive
export ICLOUD_DRIVE="$HOME/.icloud-drive"

PATH="$CODE_DIR/go_use/bin:$PATH"

## Source private (encrypted) ENV variables via automounted disk image
source "/Volumes/secure-dotfiles/.env"

## Increase limit of open file descriptors because watch processes
ulimit -n 10000

# Prepare Rails
#export RAILS_ENV="development"
#export RACK_ENV="development"

# Prepare Ruby
export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

## Load aliases
source "$HOME/.aliases.bash"
source `which go_use_aliases`
source `which go_use_fixup_env`

# Alias Hub as Git
eval "$(hub alias -s)"

# load custom PS1 prompt
source $HOME/.bin/ps1

# Prepare Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform_tools

# gsl
export PATH="/usr/local/opt/gsl@1/bin:$PATH"

# Make sure /usr/local/bin is first
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
