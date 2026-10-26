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

# Install system packages (Linux), through sudo unless already root. Each package
# goes to the first package manager that can install it: apt-get, then dnf (or
# yum where there's no dnf). Some machines have several that each carry different
# packages (Bloomberg RHEL's apt-get has neovim but no fzf; its dnf has fzf). A
# package none can install is a warning, not a failure.
pkg_install() {
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

# Install packages on either OS: with Homebrew on macOS (formulae and casks,
# skipping ones already installed), with pkg_install on Linux.
pkgs() {
  if is_macos; then
    install_missing 'brew list --formula -1; brew list --cask -1' 'brew install' "$@"
  else
    pkg_install "$@"
  fi
}

# Install each package that `list_cmd` doesn't already show, with `install_cmd`.
# A package like tap/repo/name is matched on its last part.
install_missing() {
  local list_cmd=$1 install_cmd=$2 installed package
  shift 2
  installed=" $(eval "$list_cmd" | tr '\n' ' ') "
  for package in "$@"; do
    if [[ "$installed" == *" ${package##*/} "* ]]; then
      echo "* $package - already installed"
    else
      eval "$install_cmd \"\$package\""
      echo "* $package - newly installed"
    fi
  done
}
