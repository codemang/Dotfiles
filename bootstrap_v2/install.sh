#!/usr/bin/env bash
# Install ingredients and recipes. See README.md.
#
# Usage: install.sh [--dry-run] <name>...
#        install.sh --list
#
# A name is an ingredient (ingredients/<name>.sh, one install step) or a recipe
# (recipes/<name>, a list of other names, one per line). Recipes nest to any
# depth. Every ingredient runs at most once per run, in the order it's first
# reached, and the run stops at the first one that fails.
#
# Plain bash 3.2 (macOS's /bin/bash), so it runs on a machine with nothing
# installed: no associative arrays.

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$ROOT")}"
export BOOTSTRAP_LIB="$ROOT/lib/utils.sh"

# shellcheck source=lib/utils.sh
source "$BOOTSTRAP_LIB"

plan=()      # ingredients to run, in order
planned=" "  # the same, space-separated, for membership tests
stack=" "    # recipes being expanded, to catch cycles

usage() {
  sed -n '4,5p' "${BASH_SOURCE[0]}" | sed 's/^# //'
  exit 2
}

list() {
  local file
  echo "Recipes:"
  for file in "$ROOT"/recipes/*; do
    printf '  %-22s %s\n' "$(basename "$file")" "$(names_in "$file" | tr '\n' ' ')"
  done
  echo "Ingredients:"
  for file in "$ROOT"/ingredients/*.sh; do
    printf '  %-22s %s\n' "$(basename "$file" .sh)" "$(sed -n 's/^# //p' "$file" | head -n 1)"
  done
}

# The names a recipe file lists: one per line, # comments and blank lines skipped.
names_in() {
  sed -e 's/#.*//' -e 's/[[:space:]]//g' "$1" | grep -v '^$' || true
}

# Add `name` to the plan: an ingredient once, a recipe's names in order.
expand() {
  local name=$1 recipe="$ROOT/recipes/$1" ingredient="$ROOT/ingredients/$1.sh" child
  if [[ -f "$recipe" && -f "$ingredient" ]]; then
    die "'$name' is both a recipe and an ingredient; rename one"
  elif [[ -f "$ingredient" ]]; then
    [[ "$planned" == *" $name "* ]] && return
    plan+=("$name")
    planned+="$name "
  elif [[ -f "$recipe" ]]; then
    [[ "$stack" == *" $name "* ]] && die "recipe cycle:${stack}$name"
    stack+="$name "
    for child in $(names_in "$recipe"); do
      expand "$child"
    done
    stack=${stack% "$name" }" "
  else
    die "no recipe or ingredient named '$name' (see --list)"
  fi
}

main() {
  local dry_run=false names=() name i
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run) dry_run=true ;;
      --list) list; return ;;
      -h | --help) usage ;;
      -*) die "unknown option $1" ;;
      *) names+=("$1") ;;
    esac
    shift
  done
  [[ ${#names[@]} -gt 0 ]] || usage

  for name in "${names[@]}"; do
    expand "$name"
  done

  [[ ${#plan[@]} -gt 0 ]] || die "nothing to run: ${names[*]} lists no ingredients"

  if $dry_run; then
    echo "Would run, in order:"
    for i in "${!plan[@]}"; do
      echo "  $((i + 1)). ${plan[$i]}"
    done
    return
  fi

  for i in "${!plan[@]}"; do
    name=${plan[$i]}
    section "${name} ($((i + 1))/${#plan[@]})"
    # Each ingredient runs in its own strict-mode shell with the helpers loaded,
    # so one can't change another's variables or options.
    if ! bash -c 'set -euo pipefail; source "$1"; source "$2"' _ "$BOOTSTRAP_LIB" "$ROOT/ingredients/$name.sh"; then
      die "'$name' failed; not running the rest: ${plan[*]:$((i + 1))}"
    fi
  done
  section "done: ${names[*]}"
}

main "$@"
