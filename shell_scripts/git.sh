# ---- Public Interface ----

# Make 'git' command always use the fastest git executable for the current
# OS/environment. This must be the first alias, to ensure all other
# aliases/functions use it.
alias git="fast_git"

# -- List Branches --
alias gbr="git branch"

# -- Change Branches --
alias co="git checkout" # Switch branches
alias col="git checkout -" # Switch to last branch
com() {
  git checkout $(main_branch)
}

# -- Create Branches --
alias cob="git checkout -b" # Create new branch

# -- Delete Branches --
alias cod="git branch -d" # Delete branch if merged
alias codd="git branch -D" # Force delete branch

# -- Push Branches --
alias push="git push" # Normal push
alias fpush="git push -f" # Push by force
npush() { # Push a new branch
  git push -u origin $(git rev-parse --abbrev-ref HEAD)
}

# -- Pull Branches --
alias gp="git pull" # Regular pull
gpm() { # Switch to the main/master branch and fetch the latest from upstream or origin.
  git checkout $(main_branch) && git fetch $(main_remote) && git rebase $(main_remote)/$(main_branch)
}

# -- Viewing Changes --
alias gstat="git status"
alias gdiff="git diff"

# -- Commiting --
alias cmt="git commit -m"
alias cmta="git commit -am"
alias amend="git commit --amend"
alias rollup="git commit --amend --no-edit"
alias rollupa="git commit -a --amend --no-edit"
alias wip="git commit -am 'WIP'"
squash() {
  git reset --soft $(git merge-base $(main_branch) HEAD)
  git commit
}


# -- Log Commits --
glm() { # Log commits that are not on main, one line per commit
  git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit $(main_branch)..HEAD
}
glmv() { # Log commits that are not on main, full commit message.
  git log $(main_branch)..HEAD
}
alias gla="git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit" # Log all commits, one line per commit.
alias glav="git log" # Log all commits, full commit message.

# -- Rebasing --
rem() { # Rebase off the main/master branch.
  git rebase -i $(main_branch)
}
alias rec="git rebase --continue" # Continue a rebase.
alias reab="git rebase --abort" # Abort a rebase.
re() { # Rebase the last n commits.
  git rebase -i HEAD~${1-1}
}
# Commit all files that had diffs in them after rebasing, and continue the
# rebase.
recmc() {
  git add $(git --no-pager diff --name-only --diff-filter=U)
  git rebase --continue
}

# -- Undoing Changes --

# Set contents of file to that of origin.
mirrorf() {
  git restore -s $(select_git_remote)/$(main_branch) $*
}

# Set contents of repo to that of origin, overwriting any changes, with no chance of retrieval.
mirrorb() {
  branch=""
  if [ ! -z $1 ]
  then
    branch="$1"
  else
    branch="$(current_branch)"
  fi
  confirm_cmd "Are you sure you want to reset --hard to remote branch $branch" "git fetch; git reset --hard $(select_git_remote)/$branch"
}

mirrorm() {
  mirror $(main_branch)
}

undo() { # Remove last #{n} commit/s, with changes still present.
  git reset HEAD~${1-1} --mixed
}

# -- Stashing --
alias gs="git stash"
alias gsl="git stash list"
alias gsa="git stash apply"

# gsd() {
#   git stash drop stash@{$1}
# }

# -- Cold/Warm Storage --
git_mv_cold_storage() {
  git update-ref refs/hidden/$1 $1
  echo "Moved branch $1 to cold storage."
  git branch -D $1
}

git_mv_warm_storage() {
  git checkout -b $1 refs/hidden/$1
}

git_list_cold_storage() {
  git show-ref | grep hidden | awk '{ print $2 }' | awk 'BEGIN { FS="refs/hidden/" } ; { print $2 }'
}

git_rm_cold_storage() {
  git update-ref -d refs/hidden/$1
}

# Bind ctrl-g to fuzzy-find over changed files in Git.
bind '"\C-g":"$(fuzzy_find_changed_files)\015"'

# Bind ctrl-g to fuzzy-find over Git branches.
bind '"\C-b":"$(fuzzy_find_branches)\015"'

# ---- Private Helpers ----

is_win_dir() {
  case $PWD/ in
    /mnt/*) return $(true);; # In WSL partition, but in Windows folders.
    /c/*) return $(true);; # In Windows partition, and therefore Windows folders too.
    *) return $(false);; # In WSL partition, and in WSL folders.
  esac
}

# Speed up `git status` and other git commands in WSL.
# https://github.com/microsoft/WSL/issues/4401#issuecomment-670080585
fast_git() {
  if is_win_dir; then
    git.exe "$@"
  else
    /usr/bin/git "$@"
  fi
}

# Removes asterisk from current branch.
# https://stackoverflow.com/a/51697007
list_git_branches() {
  fast_git for-each-ref --format='%(refname:short)' refs/heads/
}

fuzzy_find_branches() {
  # For some reason, doing `list_git_branches | fzf` would occasionally hang on WSL,
  # but the more verbose approach does not.
  branches=$(list_git_branches)
  chosen_branch=$(echo -e "$branches" | fzf)
  echo $chosen_branch
}

# Return 'main' or 'master', depending on which branch name is the primary for
# this repo.
main_branch() {
  git branch -l main master --format '%(refname:short)'
}

# Return 'upstream' if exists, otherwise 'origin'.
main_remote() {
    if git remote | grep -q 'upstream'; then
      echo "upstream"
    else
        echo "origin"
    fi
}

current_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

select_git_remote() {
  num_remotes=$(git remote | wc -l)

  if [[ "$num_remotes" -eq 1 ]]; then
    remote=$(git remote)
  else
    remote=$(git remote | fzf)
  fi

  echo $remote
}

# Helper
confirm_cmd() {
  echo -n "$1? [y/n]: "
  read answer

  if [ "$answer" = "y" ]
  then
    eval $2
  else
    echo "Aborting"
  fi
}

changed_files() {
  git --no-pager diff --name-only $(main_branch)
}

fuzzy_find_changed_files() {
  # For some reason, doing `changed_files | fzf` would occasionally hang on WSL,
  # but the more verbose approach does not.
  files=$(changed_files)
  chosen_file=$(echo -e "$files" | fzf)
  echo $chosen_file
}

