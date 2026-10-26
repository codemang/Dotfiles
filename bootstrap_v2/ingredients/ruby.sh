# Ruby 3.4.4 via ruby-install, made the default in ~/.ruby-version (needs ruby-tools)
version=3.4.4
if [[ -d "$HOME/.rubies/ruby-$version" ]]; then
  ok "Ruby $version already installed"
else
  ruby-install ruby "$version"
fi
echo "$version" > "$HOME/.ruby-version"
