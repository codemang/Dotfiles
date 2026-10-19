#!/bin/bash

# Herdr version of the tmux 'is_vim' pane navigation. If the focused pane is
# running Vim, forward the key so Vim can move between its own splits.
# Otherwise, move Herdr focus to the neighboring pane.
#
# Usage: herdr_navigate.sh <left|down|up|right> <key>

direction=$1
key=$2

process_info=$(herdr pane process-info --current)
pane_id=$(jq -r '.result.process_info.pane_id' <<< "$process_info")
foreground_processes=$(jq -r '.result.process_info.foreground_processes[].name' <<< "$process_info")

if grep -iqE '^g?(view|n?vim?x?)(diff)?$' <<< "$foreground_processes"; then
  herdr pane send-keys "$pane_id" "$key"
else
  herdr pane focus --current --direction "$direction"
fi
