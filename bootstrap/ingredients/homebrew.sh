# Homebrew itself (macOS)
require_macos
if command -v brew > /dev/null; then
  ok "Homebrew already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
