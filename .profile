# Sticking with bash for now.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Initialize my "xenv" language runtime managers if installed
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Handle Mac platforms
CPU=$(uname -p)
if [[ "$CPU" == "arm" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    alias oldbrew="/usr/local/bin/brew"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    export PATH="/usr/local/bin:$PATH"
fi

# nvm deactivate 2>&1 /dev/null || echo "No nvm yet, that's okay."
# brew unlink node | grep -e "0 symlinks removed" > /dev/null || echo "Had to remove a brew-installed node, use nvm!" && brew uninstall --ignore-dependencies node
# npm config delete prefix
export NVM_DIR="$HOME/.nvm"

unset npm_config_prefix
unset PREFIX
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" 2>&1
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# GCP was installing an ancient version of node:
# nvm use --delete-prefix v10.17.0
if [ -n "$CLAUDECODE" ]; then
    nvm use default --silent
else
    nvm use default
fi
# node --version 2>&1 /dev/null || nvm use default
# nvm use `cat .nvmrc` && npm config delete prefix || echo "Not in a .nvmrc dir"

# Activate yarn berry
corepack enable

# Additional PATH configuration

## My own scripts
PATH="$HOME/.bin:$PATH"
PATH="/usr/local/sbin:$PATH"
# PATH="/usr/local/share/npm/bin:$PATH"

# Bash settings

## stickier .bash_history
shopt -s histappend

## Set up bash git completion (skip for Claude agents - not needed)
if [ -z "$CLAUDECODE" ]; then
  if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]; then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
  elif [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
  else
    echo "No git-completion.bash found"
  fi
  if [ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]; then
    source /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh
  elif [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh ]; then
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
  else
    echo "No git-prompt.sh found"
  fi

  ## Set up tab-completion (requires `brew install bash-completion`)
  # Cache brew --prefix to avoid slow call each shell init
  BREW_PREFIX="${BREW_PREFIX:-$(brew --prefix)}"
  if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
    source "$BREW_PREFIX/etc/bash_completion"
  fi

  ## Setup yarn tab-completion
  [ -f ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash ] && . ~/.config/yarn/global/node_modules/tabtab/.completions/yarn.bash
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
# Conditionally enable my go_use utility
if command -v go_use_aliases &>/dev/null; then
  source `which go_use_aliases`
  source `which go_use_fixup_env`
fi

# GPG Stuff
if [ -S ~/.gnupg/S.gpg-agent ]; then
    [ -z "$CLAUDECODE" ] && echo "[gpg-agent]: status is good."
else
    eval $(gpg-agent --daemon)
fi

## Fix GPG "Inappropriate ioctl for device"
export GPG_TTY=$(tty)

# load custom PS1 prompt
source $HOME/.bin/ps1

# Prepare Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# gsl
export PATH="/usr/local/opt/gsl@1/bin:$PATH"

export PATH="/usr/local/opt/openssl/bin:$PATH"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/opt/openssl/lib/"

# Python shit
export PATH="$HOME/.local/bin:$PATH"

#npm config delete prefix
#unset npm_config_prefix

. "$HOME/.cargo/env"
