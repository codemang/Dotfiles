function isWinDir {
  # echo "fast git"
  case $PWD/ in
    /mnt/*) return $(true);;
    *) return $(false);;
  esac
}

# Speed up `git status` and other git commands
# https://github.com/microsoft/WSL/issues/4401#issuecomment-670080585
function fast_git {
  if isWinDir
  then
    git.exe "$@"
  else
    /usr/bin/git "$@"
  fi
}

alias git="fast_git"

alias gbranches="git for-each-ref --format='%(refname:short)' refs/heads/"

function fuzzy_find_branches() {
  # For some reason, doing `gbranches | fzf` would occasionally hang, but the
  # more verbose approach does not.
  branches=$(gbranches)
  chosen_branch=$(echo -e "$branches" | fzf)
  echo $chosen_branch
}

function main_branch() {
  # Return whether the 'main' branch is called 'master' or 'main'.
  # https://stackoverflow.com/a/68098145
  git branch -l master main
}

alias g="git"

function git_remote() {
  num_remotes=$(git remote | wc -l)

  if [[ "$num_remotes" -eq 1 ]]; then
    remote=$(git remote)
  else
    remote=$(git remote | fzf)
  fi

  echo $remote
}

# Checkout
alias co="git checkout" # Switch branches
alias cob="git checkout -b" # Create new branch
alias cod="git branch -d" # Delete branch if merged
alias codd="git branch -D" # Force delete branch
alias col="git checkout -" # Switch to last branch
function com() {
  git checkout $(main_branch)
}
alias unstage="git reset HEAD"

# Push/Pull
alias push="git push"
alias fpush="git push -f"
alias pusho="git push origin"
alias pull="git pull"
alias pullo="git pull origin"
alias gfo="git fetch origin"

function npush() {
  git push -u origin $(git rev-parse --abbrev-ref HEAD)
}

# Commit
alias cmt="git commit -m"
alias cmta="git commit -am"
alias amend="git commit --amend"
alias amenda="git commit -a --amend"
alias amendn="git commit --amend --no-edit"
alias amendan="git commit -a --amend --no-edit"
alias wip="git commit -am 'WIP'"

alias gdiff="git diff"
alias gcp="git cherry-pick"

function pushn() {
  git push origin $(git_branch)
}

# Checkout git branch with fzf
function cof() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
}

function codf() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git branch -d $(echo "$branch" | sed "s/.* //")
}

function coddf() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git branch -D $(echo "$branch" | sed "s/.* //")
}

function git_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

 # Set contents of file to that of origin.
 function mirrorf() {
   git restore -s $(git_remote)/$(main_branch) $*
 }

# Set contents of repo to that of origin, overwriting any changes, with no chance of retrieval.
function mirror() {
  branch=""
  if [ ! -z $1 ]
  then
    branch="$1"
  else
    branch="$(git_branch)"
  fi
  confirm_cmd "Are you sure you want to reset --hard to remote branch $branch" "git fetch; git reset --hard $(git_remote)/$branch"
}

function mirrorm() {
  mirror $(main_branch)
}

# Remove last #{n} commit/s, removing any changes, with no chance of retrieving.
function wipe() {
  confirm_cmd "Are you sure you want to wipe your changes" "git add -A; git commit -qm 'WIPE SAVEPOINT'; git reset HEAD~${1-1} --hard"
}

# Remove last #{n} commit/s, with changes still present.
function undo() {
  git reset HEAD~${1-1} --mixed
}

function reu() {
  git rebase -i HEAD~$1
}

# status
alias cubr="git branch"
alias stat="git status"
alias pstat="git status -s"
alias log="git log --graph"
alias logo="git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit"

alias diff="git diff"
alias cherry="git cherry -v"

# rebase
function gm() {
  git checkout $(main_branch) && git pull origin $(main_branch)
}
function rem() {
  git rebase -i $(main_branch)
}
alias rec="git rebase --continue"
alias reab="git rebase --abort"
function re() {
  git rebase -i HEAD~${1-1}
}


# Helper
function confirm_cmd() {
  echo -n "$1? [y/n]: "
  read answer

  if [ "$answer" = "y" ]
  then
    eval $2
  else
    echo "Aborting"
  fi
}

function greplog() {
  git log --grep="$*"
}

function greplogo() {
  git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit --grep="$*"
}

# TODO: Find way to get branch auto-complete
function git_mv_cold_storage() {
  git update-ref refs/hidden/$1 $1
  echo "Moved branch $1 to cold storage."
  git branch -D $1
}

function git_mv_warm_storage() {
  git checkout -b $1 refs/hidden/$1
}

function git_list_cold_storage() {
  git show-ref | grep hidden | awk '{ print $2 }' | awk 'BEGIN { FS="refs/hidden/" } ; { print $2 }'
}

function git_rm_cold_storage() {
  git update-ref -d refs/hidden/$1
}

function gmu() {
  git checkout $(main_branch) && git fetch upstream && git rebase upstream/$(main_branch)
}

# Use ngh to find GitHub PRs
# alias proc="ngh pr -o -c"
# alias proca="ngh pr -o -c -a"
# alias pro="ngh pr -o"
# alias proa="ngh pr -o -a"

function gcf() {
  git --no-pager diff --name-only $(main_branch)
}

function fuzzy_find_changed_files() {
  # For some reason, doing `gcf | fzf` would occasionally hang on WSL,
  # but the more verbose approach does not.
  files=$(gcf)
  chosen_file=$(echo -e "$files" | fzf)
  echo $chosen_file
}

# When rebasing and dealing with merge conflicts, this command stages all files
# that needed to be addressed and continues the rebase.
function recmc() {
  git add $(git --no-pager diff --name-only --diff-filter=U)
  git rebase --continue
}

alias gs="git stash"
alias gsl="git stash list"
alias gsa="git stash apply"
