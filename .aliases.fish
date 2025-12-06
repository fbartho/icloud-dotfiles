# aliases.fish - Fish-compatible aliases
# Translation of .aliases.sh

# Source private aliases if they exist (fish versions)
if test -f "/Volumes/secure-dotfiles/work_aliases.fish"
    source "/Volumes/secure-dotfiles/work_aliases.fish"
end
if test -f "/Volumes/secure-dotfiles/other_aliases.fish"
    source "/Volumes/secure-dotfiles/other_aliases.fish"
end

# Reload config
alias resource="source ~/.config/fish/config.fish"

# macOS system commands
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias saferestart="osascript -e 'tell app \"System Events\" to restart'"
alias safeshutdown="osascript -e 'tell app \"System Events\" to shut down'"
alias sleepnow="pmset sleepnow"
alias displaysleepnow="pmset displaysleepnow"

# Time Machine
alias timemachine_info="sudo tmutil listbackups"
alias timemachine_start="sudo tmutil startbackup"
alias timemachine_stop="sudo tmutil stopbackup"
alias timemachine_boost="sudo sysctl debug.lowpri_throttle_enabled=0"
alias timemachine_regular="sudo sysctl debug.lowpri_throttle_enabled=1"

# System versions
alias versions="sw_vers; echo '---'; xcodebuild -version"

# Node modules
alias find_node_modules="find . -name 'node_modules' -type d -prune -print"
alias nuke_node_modules="find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;"

# iOS Simulator
alias simshot="xcrun simctl io booted screenshot"
alias simaddmedia="xcrun simctl addmedia booted"
alias simopenurl="xcrun simctl openurl booted"
alias simappcontainer="xcrun simctl get_app_container booted"
alias lsregister="/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister"

# Git shortcuts
alias gb="git branch"
alias gba="git branch -a"
alias gc="git commit -v"
alias gca="git commit -v -a"
alias gd="git diff"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias glog="git log --abbrev-commit --pretty=oneline"
alias grh="git reset --HARD"
alias gco="git checkout"
alias glhc="git log -1 --format=%H | pbcopy"
alias gg="git grep -n"
alias hub="git"

# Open GitUp at repo root
alias gitup="open -a GitUp (git rev-parse --show-toplevel)"

# Xcode helpers
alias xcp="openx"
alias podxcp="pod install && openx"

# Utilities
alias fix_audio="sudo kill -9 (ps ax | grep 'coreaudio[a-z]' | awk '{print \$1}')"
alias restartsound="fix_audio"
alias fix_dns="sudo killall -HUP mDNSResponder"
alias restartdns="fix_dns"

# Chrome
alias chrome="open -a 'Google Chrome'"

# NVM upgrade
alias nvm_upgrade_stable="nvm install stable --reinstall-packages-from=(nvm current)"

# Strip ANSI colors
alias strip_color="sed -e 's/\x1b\[[0-9;]*m//g'"

# tac fallback
if not command -v tac >/dev/null 2>&1
    alias tac="tail -r"
end
