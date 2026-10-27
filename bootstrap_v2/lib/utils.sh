#!/usr/bin/env bash
# Helpers for install.sh and every ingredient, which run with this sourced.
# $DOTFILES_DIR is the repo root.

green() { printf '\033[32m%s\033[0m\n' "$*"; }
ok() { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
die() {
  echo "❌ $*" >&2
  exit 1
}

section() {
  echo
  green "=================================================================="
  green "  $(tr '[:lower:]' '[:upper:]' <<< "$*")"
  green "=================================================================="
}

is_macos() { [[ "$(uname -s)" == Darwin ]]; }
is_linux() { [[ "$(uname -s)" == Linux ]]; }
require_macos() { is_macos || die "this ingredient is macOS-only"; }
require_linux() { is_linux || die "this ingredient is Linux-only"; }

# Symlink $DOTFILES_DIR/<source> to <target>. An existing, different file there
# is moved to <target>.replaced first; a correct link is left alone.
link() {
  local source="$DOTFILES_DIR/$1" target="${2/#\~/$HOME}"
  target=${target%/}
  if [[ "$(readlink "$target" 2> /dev/null)" == "${source%/}" || "$(readlink "$target" 2> /dev/null)" == "$source" ]]; then
    ok "already linked: $target"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    warn "replacing $target (old copy at $target.replaced)"
    mv "$target" "$target.replaced"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  ok "linked: $target -> $source"
}

# ---- Installing packages ----
#
# install_packages works on either OS. The others each use one package manager.

# Install packages on either OS: Homebrew on macOS, the system's package managers
# on Linux.
install_packages() {
  if is_macos; then
    brew_install "$@"
  else
    linux_install "$@"
  fi
}

# Install Homebrew formulae or casks, skipping ones already installed. Homebrew
# works out which a name is; pass --cask first to insist on casks.
brew_install() {
  require_macos
  if [[ "${1:-}" == --cask ]]; then
    shift
    _install_missing "$(brew list --cask -1)" brew install --cask -- "$@"
  else
    _install_missing "$(brew list --formula -1; brew list --cask -1)" brew install -- "$@"
  fi
}

# Install system packages on Linux, through sudo unless already root. Each package
# goes to the first package manager that can install it: apt-get, then dnf (or
# yum where there's no dnf). Some machines have several that each carry different
# packages (Bloomberg RHEL's apt-get has neovim but no fzf; its dnf has fzf). A
# package none can install is a warning, not a failure.
linux_install() {
  require_linux
  # A string, not an array: bash < 4.4 (macOS, RHEL 7) treats an empty array as
  # unset under `set -u`.
  local sudo="" managers=() manager package installed
  [[ $(id -u) -eq 0 ]] || sudo=sudo
  command -v apt-get > /dev/null && managers+=(apt-get)
  if command -v dnf > /dev/null; then
    managers+=(dnf)
  elif command -v yum > /dev/null; then
    managers+=(yum)
  fi
  [[ ${#managers[@]} -gt 0 ]] || die "no apt-get, dnf or yum to install: $*"
  [[ " ${managers[*]} " == *" apt-get "* ]] && $sudo apt-get update -qq > /dev/null 2>&1
  for package in "$@"; do
    installed=""
    for manager in "${managers[@]}"; do
      if [[ $manager == apt-get ]]; then
        DEBIAN_FRONTEND=noninteractive $sudo apt-get install -y -qq "$package" > /dev/null 2>&1 && installed=$manager
      else
        $sudo "$manager" install -y -q "$package" > /dev/null 2>&1 && installed=$manager
      fi
      [[ -n "$installed" ]] && break
    done
    if [[ -n "$installed" ]]; then
      ok "$package (via $installed)"
    else
      warn "couldn't install $package with ${managers[*]}"
    fi
  done
}

# Install global gems for mise's Ruby, skipping ones already installed.
gem_install() {
  activate_mise
  _install_missing "$(gem list --no-versions)" gem install -- "$@"
}

# Install global npm packages for mise's Node, skipping ones already installed.
npm_install() {
  activate_mise
  _install_missing "$(ls "$(npm root -g)")" npm install -g -- "$@"
}

# Put mise's tools (node, gem, npm, python) on PATH, for ingredients that use them.
activate_mise() {
  export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
  # The repo's config, in case the dotfiles step hasn't linked it into place yet.
  export MISE_GLOBAL_CONFIG_FILE="$DOTFILES_DIR/dotfiles/mise.toml"
  # So gem, npm and pip can verify HTTPS behind a corporate TLS proxy.
  source "$DOTFILES_DIR/shell_scripts/ca_certs.sh"
  command -v mise > /dev/null || die "mise isn't installed; run the mise ingredient first"
}

# Usage: _install_missing <installed names, one per line> <command>... -- <package>...
# Run `<command> <package>` for each package not among the installed names. A
# package like tap/repo/name is matched on its last part.
_install_missing() {
  local installed=" $(tr '\n' ' ' <<< "$1") " command=() package
  shift
  while [[ $1 != -- ]]; do
    command+=("$1")
    shift
  done
  shift
  for package in "$@"; do
    if [[ "$installed" == *" ${package##*/} "* ]]; then
      echo "* $package - already installed"
    else
      "${command[@]}" "$package"
      echo "* $package - newly installed"
    fi
  done
}
