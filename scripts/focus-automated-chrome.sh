#!/bin/bash
# Focus the Chrome instance launched with --enable-automation (by Selenium/ChromeDriver)
# The main browser process has --enable-automation but no --type= flag (child processes have --type=renderer, etc.)
pid=$(ps x -o pid,command | grep '[G]oogle Chrome' | grep -- '--enable-automation' | grep -v -- '--type=' | awk '{print $1}' | head -1)

if [ -n "$pid" ]; then
    osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $pid) to true"
else
    # Fallback: just focus normal Chrome
    open -a 'Google Chrome'
fi
