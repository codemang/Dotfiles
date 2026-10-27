# Global npm packages, for mise's Node (needs mise)
packages=(
  instant-markdown-d
  eslint_d # Formats JSX in NeoVim.
  neovim
  npm
  vtop
  yarn
)
npm_install "${packages[@]}"
