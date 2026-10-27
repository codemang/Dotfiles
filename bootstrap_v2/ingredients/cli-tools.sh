# Command-line tools for any machine: git, fzf, ripgrep, tmux, neovim, ...
install_packages \
  git \
  git-lfs \
  curl \
  fzf \
  ripgrep \
  tmux \
  neovim \
  lua-language-server \
  htop \
  tldr \
  diff-so-fancy \
  nmap \
  cmake
# Clipboard access for neovim; macOS has pbcopy built in.
is_linux && install_packages xclip
true
