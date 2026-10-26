# Global npm packages
packages=(
  instant-markdown-d
  eslint_d # Formats JSX in NeoVim.
  neovim
  npm
  vtop
)
install_missing 'ls "$(npm root -g)"' 'npm install -g' "${packages[@]}"
