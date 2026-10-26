# Oh My Zsh, and zsh as the login shell (run after shell-rc)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  "$HOME/.oh-my-zsh/tools/upgrade.sh" || warn "couldn't upgrade Oh My Zsh"
else
  # KEEP_ZSHRC: keep the ~/.zshrc shell-rc made, instead of swapping in its template.
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
zsh_path=$(command -v zsh)
grep -qxF "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
if [[ "$SHELL" == *zsh ]]; then
  ok "zsh is already the login shell"
else
  chsh -s "$zsh_path"
fi
