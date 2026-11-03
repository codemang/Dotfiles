# Symlink git, mise, tmuxinator, herdr and other config files from this repo into place
link dotfiles/gitconfig ~/.gitconfig
link dotfiles/gitignore_global ~/.gitignore_global
link dotfiles/tmuxinator ~/.config/tmuxinator
link dotfiles/mise.toml ~/.config/mise/config.toml
link dotfiles/herdr.toml ~/.config/herdr/config.toml
link dotfiles/herdr-reviewr.toml ~/.config/herdr/plugins/config/persiyanov.reviewr/config.toml
# Silences the "Last login..." message: https://osxdaily.com/2010/06/22/remove-the-last-login-message-from-the-terminal/
link dotfiles/hushlogin ~/.hushlogin
# Run by name from tmux.conf. ~/.local/bin is on PATH (shell_scripts/mise.sh) and,
# unlike /usr/local/bin, needs no root.
link util/tmux_switch_session.sh ~/.local/bin/tmux_switch_session
