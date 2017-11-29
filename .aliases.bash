source "/Volumes/secure-dotfiles/work_aliases.sh"
source "/Volumes/secure-dotfiles/other_aliases.sh"
alias resource="source ~/.profile"

alias open="open2"
alias up="svn up"
alias st="svn st"
alias octave="exec '/Applications/Octave.app/Contents/Resources/bin/octave'"

alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias saferestart="osascript -e 'tell app \"System Events\" to restart'"
alias safeshutdown="osascript -e 'tell app \"System Events\" to shut down'"
alias sleepnow="pmset sleepnow"
alias displaysleepnow="pmset displaysleepnow"

# Get the system & xcode versions!
alias versions="{ sw_vers; echo "---"; xcodebuild -version; }"

alias rmsvn="find ./ -name .svn -exec rm -rf {} \;"
alias rmnonsvn="svn status | grep ? | awk '{print $2}' | xargs rm -rf"

# Open Xcodeworkspace but fallback to xcodeproj
# alias xcp="open *.xc*"
# alias xcp="if [ \"$(ls *.xcworkspace 2> /dev/null | wc -l)\" != \"       0\" ]; then    open *.xcworkspace; else    open *.xcodeproj; fi"
openx() {
    fileToOpen='';
    for file in `find . -maxdepth 1 -name *.xcworkspace`; do
        fileToOpen=$file
    done

    if [ -n "$fileToOpen" ]
    then
        echo $fileToOpen
        open $fileToOpen
    else
        for file in `find . -maxdepth 1 -name *.xcodeproj`; do
            fileToOpen=$file
        done

        if [ -n "$fileToOpen" ]
        then
            echo $fileToOpen
            open $fileToOpen
        else
            echo "No xcode files to open."
        fi
    fi
}

# Shorthand version of "openx", use "xcp" instead.
alias xcp="openx"

alias podxcp="pod install && xcp"

alias esp="open -a Espresso "
alias na="rm -rf build/Debug/*.app"

alias gb="git branch"
alias gba="git branch -a"
alias gc="git commit -v"
alias gca="git commit -v -a"
alias gd="git diff"
alias gl="git pull"
alias gp="git push"
alias gst="git status"
alias glog="git log --abbrev-commit --pretty=oneline "
alias grh="git reset --HARD"
alias gco="git co"
alias gpb="push_branch"
alias glhc="git lh | pbcopy"
alias gg="git grep -n"

alias gitup="open -a GitUp `git rev-parse --show-toplevel`"

alias broforce="sudo /Users/fbarthelemy/Library/Application\ Support/Steam/SteamApps/common/Broforce/Broforce.app/Contents/MacOS/Broforce"
alias pa="sudo ~/Library/Application\ Support/Steam/SteamApps/common/Planetary\ Annihilation/PA.app/Contents/MacOS/PA"

alias fix_audio="sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'`"
alias restartsound="fix_audio"

# Removes duplicated lines keeping the first instance of a line.
alias uniq_inplace="awk '!x[\$0]++'"
alias uniq_inplace_latest="tail -r | uniq_inplace | tail -r"

# NodeJS Aliases
alias yarn_upgrade="rm yarn.lock && yarn"

