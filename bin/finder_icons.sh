#!/bin/sh
# Purpose: Turn on or off desktop icons in Mac OS X -- For Demos, Screen recordings, or Interviews!
# Original Author: Chockenberry, https://gist.github.com/chockenberry/aec61eb3ee486813782c7260102646d5

defaults read com.apple.finder CreateDesktop > /dev/null 2>&1
enabled=$?

if [ "$1" = "off" ]; then
	if [ $enabled -eq 1 ]; then
		osascript -e 'tell application "Finder" to quit'
		defaults write com.apple.finder CreateDesktop false
		open -a Finder
		echo "Desktop icons are now turned off"
	else
		echo "Desktop icons are already off"
	fi
elif [ "$1" = "on" ]; then
	if [ $enabled -eq 1 ]; then
		echo "Desktop icons are already on"
	else
		osascript -e 'tell application "Finder" to quit'
		defaults delete com.apple.finder CreateDesktop
		open -a Finder
		echo "Desktop icons now turned on"
	fi
elif [ "$1" = "status" ]; then
	if [ $enabled -eq 1 ]; then
		echo "Desktop icons are on"
	else
		echo "Desktop icons are off"
	fi
else
	echo "usage: `basename $0` ( on | off | status )"
fi