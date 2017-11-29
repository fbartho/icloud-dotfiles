# Initialize my "xenv" language runtime managers if installed
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi
if command -v nodenv &>/dev/null; then
  eval "$(nodenv init -)"
fi
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

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

## Load aliases
source "$HOME/.aliases.bash"
source `which go_use_aliases`
source `which go_use_fixup_env`

# Alias Hub as Git
eval "$(hub alias -s)"

## load custom PS1 prompt
source $HOME/.bin/ps1

export PATH="/usr/local/opt/gsl@1/bin:$PATH"

# Make sure /usr/local/bin is first
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
