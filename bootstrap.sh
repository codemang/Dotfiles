#!/usr/bin/env bash

set -eou pipefail

# Check if just is already installed
if command -v just &> /dev/null; then
  echo "just is already installed:"
  just --version
else
  echo "Installing just..."
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
  echo "just installed successfully!"
  just --version
fi

# If no argument is provided, exit after install
if [ -z "$1" ]; then
  echo "No argument provided, exiting after install."
  exit 0
fi

# If an argument is provided, call just with that argument
echo "Running 'just $1'"
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
just --justfile "$script_dir/justfile" "$1"
echo "Completed execution of 'just $1'"
