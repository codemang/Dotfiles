# Link this repo's herdr plugins (util/herdr_plugins) into herdr, enabled
if ! command -v herdr > /dev/null; then
  warn "herdr isn't installed; skipping its plugins"
  exit 0
fi
installed=$(herdr plugin list)
for dir in "$DOTFILES_DIR"/util/herdr_plugins/*/; do
  dir=${dir%/}
  name=$(basename "$dir")
  if [[ "$installed" == *"[local:$dir]"* ]]; then
    ok "herdr plugin already linked: $name"
    continue
  fi
  # A plugin of the same name linked from somewhere else (like an old checkout
  # path) is unlinked first.
  herdr plugin unlink "$name" > /dev/null 2>&1 || true
  herdr plugin link "$dir" --enabled > /dev/null
  ok "herdr plugin linked: $name"
done
