# bootstrap_v2

Machine setup in plain bash: nothing to install first, and it runs on macOS's
built-in bash 3.2. It sits alongside the old `justfile`/`Rakefile` bootstrap,
which is unchanged.

```sh
bootstrap_v2/install.sh osx              # set up a Mac
bootstrap_v2/install.sh linux            # set up a Linux machine
bootstrap_v2/install.sh cli-tools nvim-config   # just these
bootstrap_v2/install.sh --dry-run osx    # print what would run, in order
bootstrap_v2/install.sh --list           # every recipe and ingredient
```

## Ingredients and recipes

- **Ingredient** (`ingredients/<name>.sh`): one install step. Its first comment
  line is its `--list` description. It runs in its own `bash` with
  `set -euo pipefail` and `lib/utils.sh` loaded, with `$DOTFILES_DIR` set to the
  repo root.
- **Recipe** (`recipes/<name>`): a list of ingredient or recipe names, one per
  line (`#` comments allowed). Recipes nest to any depth.

A run expands its names into a list of ingredients and runs them in order.
Each ingredient runs once, however many recipes include it, and the run stops
at the first one that fails. A recipe that includes itself, directly or through
others, is an error, and so is a name used for both a recipe and an ingredient.

To add a step, add an ingredient. To group steps, add a recipe listing them.

## Helpers (`lib/utils.sh`)

| Helper | What it does |
| --- | --- |
| `link <repo path> <target>` | Symlink a repo file into place; an existing different file is moved to `<target>.replaced` |
| `install_packages <pkg>...` | Install on either OS: `brew_install` on macOS, `linux_install` on Linux |
| `brew_install [--cask] <pkg>...` | Homebrew formulae or casks, skipping installed ones (macOS) |
| `linux_install <pkg>...` | System packages, each with the first of apt-get, dnf/yum that has it, using sudo unless root; one none has is a warning (Linux) |
| `gem_install <gem>...` | Global gems for mise's Ruby, skipping installed ones |
| `npm_install <pkg>...` | Global npm packages for mise's Node, skipping installed ones |
| `activate_mise` | Put mise's tools on PATH and point them at the system's certificates |
| `require_macos`, `require_linux` | Stop the ingredient on the wrong OS |
| `ok`, `warn`, `die`, `green`, `section` | Output |
