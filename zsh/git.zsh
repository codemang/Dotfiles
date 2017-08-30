# Checkout
alias co="git checkout" # Switch branches
alias cob="git checkout -b" # Create new branch
alias cod="git branch -d" # Delete branch if merged
alias codd="git branch -D" # Force delete branch
alias col="git checkout -" # Switch to last branch
alias unstage="git reset HEAD"

# Push/Pull
alias push="git push"
alias pusho="git push origin"
alias pull="git pull"
alias pullo="git pull origin"

# Commit
alias cmt="git commit -am"
alias amend="git commit -a --amend"
alias amendn="git commit -a --amend --no-edit"
alias wip="git commit -am 'WIP'"


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

function git_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

 # Set contents of file to that of origin.
alias mirrorf="git checkout origin/master --"

# Set contents of repo to that of origin, overwriting any changes, with no chance of retrieval.
function mirror() {
  branch=""
  if [ ! -z $1 ]
  then
    branch="$1"
  else
    branch="$(git_branch)"
  fi
  confirm_cmd "Are you sure you want to reset --hard to remote branch $branch" "git fetch; git reset --hard origin/$branch"
}

function mirrorm() {
  mirror master
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
  git checkout master
  if [ $? -eq 0 ]
  then
    git branch --merged ${1-master} | grep -v " ${1-master}$" | xargs git branch -d;
  fi
}

# status
alias cubr="git branch"
alias stat="git status"
alias pstat="git status -s"
alias log="git log --graph"
alias logo="git log --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr) %C(blue)<%an>%Creset' --abbrev-commit"

# alias diff="git diff"
alias cherry="git cherry -v"

# rebase
alias gm="git checkout master && git pull origin master"
alias rem="git rebase -i master"
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

alias g="git"
