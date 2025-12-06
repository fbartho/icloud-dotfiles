# .aliases.nu - Nushell aliases

# Reload config (nushell can't alias `source`, use exec)
def resource [] { exec nu }

# Git shortcuts
alias gst = git status
alias gb = git branch
alias gba = git branch -a
alias gc = git commit -v
alias gca = git commit -v -a
alias gd = git diff
alias gl = git pull
alias gp = git push
alias glog = git log --abbrev-commit --pretty=oneline
alias gco = git checkout
alias gg = git grep -n
alias grh = git reset --HARD
alias hub = git

# Open GitUp at repo root
def gitup [] { ^open -a GitUp (git rev-parse --show-toplevel) }

# macOS system
alias lock = /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
alias saferestart = osascript -e 'tell app "System Events" to restart'
alias safeshutdown = osascript -e 'tell app "System Events" to shut down'
alias sleepnow = pmset sleepnow
alias displaysleepnow = pmset displaysleepnow
alias fix_dns = sudo killall -HUP mDNSResponder
alias restartdns = fix_dns
alias chrome = ^open -a "Google Chrome"
alias lsregister = /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister

# iOS Simulator
alias simshot = xcrun simctl io booted screenshot
alias simaddmedia = xcrun simctl addmedia booted
alias simopenurl = xcrun simctl openurl booted
alias simappcontainer = xcrun simctl get_app_container booted

# Time Machine
alias timemachine_info = sudo tmutil listbackups
alias timemachine_start = sudo tmutil startbackup
alias timemachine_stop = sudo tmutil stopbackup
alias timemachine_boost = sudo sysctl debug.lowpri_throttle_enabled=0
alias timemachine_regular = sudo sysctl debug.lowpri_throttle_enabled=1

# System info
def versions [] {
    print (sw_vers)
    print "---"
    print (xcodebuild -version)
}

# Node modules helpers
def find_node_modules [] {
    glob **/node_modules --depth 10 | where ($it | path type) == "dir"
}

def nuke_node_modules [] {
    find_node_modules | each {|dir| rm -rf $dir }
}

# Open Xcode workspace/project
def openx [] {
    let workspace = (glob "*.xcworkspace" | first)
    if ($workspace | is-not-empty) {
        xed $workspace
        return
    }

    let project = (glob "*.xcodeproj" | first)
    if ($project | is-not-empty) {
        xed $project
        return
    }

    if ("Package.swift" | path exists) {
        xed "Package.swift"
        return
    }

    print "No Xcode files to open."
}

alias xcp = openx
def podxcp [] { pod install; openx }
