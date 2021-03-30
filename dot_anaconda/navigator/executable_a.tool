#!/usr/bin/osascript
tell application "Terminal"
    activate
    do script ". /Users/bohr/opt/anaconda3/bin/activate && conda activate /Users/bohr/opt/anaconda3/envs/virtual_workspace; "
end tell
