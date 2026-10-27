# Mise installs itself into this directory, so add it to the path so that we
# can run `mise`.
export PATH="$HOME/.local/bin:$PATH"

if command -v mise > /dev/null; then
  ok "mise already installed: $(mise --version)"
elif is_macos; then
  brew_install mise
else
  curl -fsSL https://mise.run | sh
fi

# What Ruby needs to build from source (Node and Python install prebuilt).
if is_macos; then
  brew_install openssl@3 readline libyaml gmp
elif [[ -f /etc/redhat-release ]]; then
  linux_install gcc make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gmp-devel
else
  linux_install build-essential libssl-dev libyaml-dev libffi-dev libreadline-dev zlib1g-dev libgmp-dev
fi

# Install any languages/tools configured in our mise.toml file.
export MISE_GLOBAL_CONFIG_FILE="$DOTFILES_DIR/dotfiles/mise.toml"
mise install --yes
