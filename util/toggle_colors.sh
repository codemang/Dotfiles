#!/bin/bash

# Cycle iTerm and Neovim to the next color scheme without changing macOS's
# appearance. Saves the choice to ~/.color-scheme-env, which Neovim watches
# (nvim_chad/lua/utils/colorscheme.lua).
#
# Usage: toggle_colors.sh

# Repo root, found by following any symlink back to this file.
DOTFILES=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)

# Color schemes to cycle through, one per line. Each name is a Neovim theme and
# a file of iTerm colors in iterm/color_schemes/.
COLOR_SCHEMES="bearded-arc
solarized_light
catppuccin_latte"

# iTerm's 'Nate Color Overrides' profile, which should be the default profile.
# iTerm reloads dynamic profiles when they change, so copying a scheme's file
# here recolors every window using it. Everything besides colors comes from the
# 'Nate Defaults' profile (the scheme files' "Dynamic Profile Parent Name").
ITERM_COLORS_PROFILE="$HOME/Library/Application Support/iTerm2/DynamicProfiles/color-scheme.json"

# The current scheme, defaulting to the first one.
if [ -f ~/.color-scheme-env ]; then
  current=$(head -n 1 ~/.color-scheme-env)
else
  current=$(head -n 1 <<< "$COLOR_SCHEMES")
fi

# The scheme after the current one, wrapping around to the first.
next=$(awk -v current="$current" '
  NR == 1 { first = $0 }
  found { print; printed = 1; exit }
  $0 == current { found = 1 }
  END { if (!printed) print first }' <<< "$COLOR_SCHEMES")

echo "$next" > ~/.color-scheme-env

# Copy through a temp file so iTerm never reads a half-written profile.
tmp_profile="${TMPDIR:-/tmp}/color-scheme.json"
cp "$DOTFILES/iterm/color_schemes/$next.json" "$tmp_profile" &&
  mv "$tmp_profile" "$ITERM_COLORS_PROFILE"

echo "Color scheme: $next"
