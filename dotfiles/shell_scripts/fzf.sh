# -L follows symlinks
export FZF_DEFAULT_COMMAND='rg --files -L'
export FZF_DEFAULT_OPTS='--height 80%'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if command -v fzf > /dev/null; then
  # https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
  if [ -n "$ZSH_VERSION" ]; then
    source <(fzf --zsh)
    [ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
  else
    eval "$(fzf --bash)"
    [ -f $HOME/.fzf.bash ] && source $HOME/.fzf.bash
  fi

  # Bind ctrl-g to search over changed files in Git.
  # https://stackoverflow.com/a/51439945
  case "$(uname -sr)" in Linux*)
    # Bind ctrl-g to fuzzy-find over changed files in Git.
    bind '"\C-g":"$(fuzzy_find_changed_files)\015"'

    # Bind ctrl-g to fuzzy-find over Git branches.
    bind '"\C-b":"$(fuzzy_find_branches)\015"'
    ;;
  Darwin*) # Mac
    # Set in iTerm preferences
    ;;
  esac
fi
