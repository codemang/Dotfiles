alias gbranches="git for-each-ref --format='%(refname:short)' refs/heads/"

function main_branch() {
  branches=$(gbranches)
  does_master_branch_exist=$(echo $branches | awk '/master/')

  if [ -z "${does_master_branch_exist}" ]; then
    echo "main"
  else
    echo "master"
  fi
}

alias g="git"

# Checkout
alias co="git checkout" # Switch branches
alias cob="git checkout -b" # Create new branch
alias cod="git branch -d" # Delete branch if merged
alias codd="git branch -D" # Force delete branch
alias col="git checkout -" # Switch to last branch
alias com="git checkout $(main_branch)"
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
alias amend="git commit -a --amend"
alias amendn="git commit -a --amend --no-edit"
alias wip="git commit -am 'WIP'"

alias gdiff="git diff"
alias gcp="git cherry-pick"

# Checkout git branch with fzf
function cof() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
}

function current_git_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

 # Set contents of file to that of origin.
alias mirrorf="git checkout origin/$(main_branch) --"

# Set contents of repo to that of origin, overwriting any changes, with no chance of retrieval.
function mirror() {
  branch=""
  if [ ! -z $1 ]
  then
    branch="$1"
  else
    branch="$(current_git_branch)"
  fi
  confirm_cmd "Are you sure you want to reset --hard to remote branch $branch" "git fetch; git reset --hard origin/$branch"
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

function gclean() {
  git checkout $(main_branch)
  if [ $? -eq 0 ]
  then
    git branch --merged ${1-$(main_branch)} | grep -v " ${1-$(main_branch)}$" | xargs git branch -d;
  fi
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

alias cherry="git cherry -v"

# rebase
alias gm="git checkout $(main_branch) && git pull origin $(main_branch)"
alias gmu="git checkout $(main_branch) && git fetch upstream && git rebase upstream/$(main_branch)"
alias rem="git rebase -i $(main_branch)"
alias rec="git rebase --continue"
alias rea="git rebase --abort"
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

function changed_files() {
  git diff --name-only $(current_git_branch) $(git merge-base $(main_branch) $(current_git_branch))
}

alias gcf="git diff --name-only $(main_branch) HEAD"
alias gucf="git diff --name-only"

function vcf() {
  file=$(gcf | fzf)
  vim $file
}

function vucf() {
  file=$(gucf | fzf)
  vim $file
}
