#!/bin/bash

# Herdr version of tmux's 'swap-pane -U' / 'swap-pane -D'. Swaps the focused
# pane with the previous or next pane in the tab, wrapping around at the ends.
#
# Usage: herdr_swap_pane.sh <prev|next>

offset=$([ "$1" = "prev" ] && echo -1 || echo 1)

current=$(herdr pane current | jq -r '.result.pane | "\(.pane_id) \(.tab_id) \(.workspace_id)"')
read -r pane_id tab_id workspace_id <<< "$current"

target=$(herdr pane list --workspace "$workspace_id" | jq -r \
  --arg pane "$pane_id" --arg tab "$tab_id" --argjson offset "$offset" '
    [.result.panes[] | select(.tab_id == $tab) | .pane_id] as $panes
    | ($panes | index($pane)) as $i
    | $panes[($i + $offset) % ($panes | length)]')

[ "$target" != "$pane_id" ] && herdr pane swap --source-pane "$pane_id" --target-pane "$target"
