# Make ~/.zshrc and ~/.bashrc source this repo's zshrc and bashrc
# Each rc stays a plain file of this machine's own, with one `source` line added.
# One left as a symlink by the old bootstrap is set aside first: appending to it
# would write into the repo file it points to.
add_source_line() {
  local rc="$HOME/$1" file="$DOTFILES_DIR/$2"
  if [[ -L "$rc" ]]; then
    warn "$rc is a symlink; moving it to $rc.replaced"
    mv "$rc" "$rc.replaced"
  fi
  touch "$rc"
  if grep -qF "source \"$file\"" "$rc"; then
    ok "$rc already sources $2"
  else
    printf '\n# This repo'"'"'s shell setup (bootstrap_v2 shell-rc)\nsource "%s"\n' "$file" >> "$rc"
    ok "$rc now sources $2"
  fi
}
add_source_line .zshrc dotfiles/zshrc
add_source_line .bashrc dotfiles/bashrc
