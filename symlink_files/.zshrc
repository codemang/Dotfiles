#!/usr/local/bin/zsh
#
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="/Applications/MacVim.app/Contents/MacOS/Vim"
export ARCHFLAGS="-arch x86_64"
source "$ZSH/oh-my-zsh.sh"
setopt CORRECT

# --------------------------------------------------------
#                TERMINAL PROMPT
# --------------------------------------------------------

autoload -U colors && colors

GOOD_EXIT_STATUS_COLOR=%F{154}
BAD_EXIT_STATUS_COLOR=%F{197}
WORKING_DIRECTORY_COLOR=%F{159}
GIT_BRANCH_COLOR=%F{213}

function exit_status(){
if [ $? -eq 0 ]
  then
     echo -e "${GOOD_EXIT_STATUS_COLOR}\xE2\x9C\x93%{$reset_color%}"
  else
    echo -e "${BAD_EXIT_STATUS_COLOR}${$?}${NONE}"
  fi
}

function working_directory() {
  echo "${WORKING_DIRECTORY_COLOR}%~%{$reset_color%}"
}

function git_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

function git_prompt() {
  # if ! git rev-parse --git-dir > /dev/null 2>&1; then
  #   return 0
  # fi
  #
  # git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')

  echo "$GIT_BRANCH_COLOR$(git_branch)%{$reset_color%}"
}

function up_stream() {
  behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
  if [ $behind -gt 0 ]
  then
    echo "%F{226}↑%{$reset_color%}"
  fi
}

function down_stream() {
  ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)

  if [ $ahead -gt 0 ]
  then
    echo "%F{226}↓%{$reset_color%}"
  fi
}

parse_git_dirty() {
  if command git diff-index --quiet HEAD 2> /dev/null; then
  else
    echo "%F{196}●%{$reset_color%}"
  fi
}

function print_colors() {
  for code in {000..255}; do
    print -P -- "$code: %F{$code}$ZSH_SPECTRUM_TEXT%f"
  done
}

function arrow() {
  echo "%F{202}❯%F{208}❯%F{214}❯%{$reset_color%}"
}

PROMPT='
$(exit_status) $(working_directory) $(git_prompt) $(parse_git_dirty)$(up_stream)$(down_stream)
$(arrow) '


# --------------------------------------------------------
#                ALIASES
# --------------------------------------------------------

# LS SHORTCUTS
alias ls="ls -G"
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -al"
alias lal="ls -al"
alias lh="ls -d .??*"
alias llh="ls -ld .??*"
alias lhl="ls -ld .??*"
alias ld="ls -d */"
alias lt="ls | grep test"
alias le="find . -maxdepth 1  -type f -perm -u=x"
alias clr="clear"

# NAV SHORTCUTS
alias dl="cd ~/Downloads"
alias vbundle="cd ~/.vim/bundle"
alias lello="cd ~/lello"
alias pulp="cd ~/pulp"
alias spine="cd ~/spine"

# GIT SHORTCUTS

# checkout
alias co="git checkout"
alias cob="git checkout"

# push
alias push="git push"
alias pusho="git push origin "

# pull
alias pull="git pull"
alias pullo="git pull origin"

# commit
alias cmt="git commit -am"
alias amend="commit -a --amend --no-edit"
alias wip="git commit -am 'WIP'"

# reset
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

function undo() {
  if [ ! -z $1 ] 
  then 
    git reset HEAD~$1 --mixed
  else
    git reset HEAD^ --mixed
  fi
}


function mirror() {
  branch=""
  if [ ! -z $1 ] 
  then 
    branch="$1"
  else
    branch="$(git_branch)"
  fi
  confirm_cmd "Are you sure you want to reset --hard to remote branch $branch" "git reset --hard origin/$branch"
}

function wipe() {
  confirm_cmd "Are you sure you want to wipe your changes" "git add -A; git commit -qm 'WIPE SAVEPOINT'; git reset HEAD~${1-1} --hard"
}

function gclean() {
  git checkout master
  if [ $? -eq 0 ]
  then
    git branch --merged ${1-master} | grep -v " ${1-master}$" | xargs git branch -d; 
  fi
}

function 

# status
alias cubr="git branch"

alias stat="git status"
alias pstat="git status -s"

alias log="git log --graph"
alias logo="git log --graph --oneline"
alias gls="log --pretty=format:\"%C(yellow)%h %Creset%s%Cblue [%cn]\" --decorate"
alias gll="log --pretty=format:\"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate --numstat"

alias diff="git diff"
alias cherry="git cherry -v"

# rebase
alias gm="git checkout master && git pull origin master"
alias rem="git rebase -i master"
alias re="git rebase -i"

# MISCELLENEOUS SHORTCUTS
alias unsu="sudo -k;"
alias su="sudo -s"
alias sub="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias src="source ~/.zshrc"
alias m="make"
alias app="cd /Applications"
alias serv="python -m SimpleHTTPServer 8000"
alias editcron="env EDITOR=vim crontab -e"

# VIM
alias v="vim"
alias vimrc="vim ~/.vimrc"
alias pref="vim ~/.zshrc"
alias vtree="vim -c ':CommandT'"
alias vnerd="vim -c ':NERDTree'"
# alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"
alias vim="/usr/local/Cellar/macvim/7.4-77/MacVim.app/Contents/MacOS/Vim"
alias vack="vim -c ':Ack'"
EDITOR="/usr/local/Cellar/macvim/7.4-77/MacVim.app/Contents/MacOS/Vim"

# TMUX
alias tkill="tmux kill"

# BOOKBUB
alias sshs='ssh ubuntu@spine.kobubob.com'
alias sshp='ssh ubuntu@spine.bookbub.com'

# RAILS
alias mig="bin/rake db:migrate"
alias prep="bin/rake db:test:prepare"

# VAGRANT
alias vup="vagrant up"
alias vdest="vagrant destroy"
alias vssh="vagrant ssh"

export LD_BIND_NOW=1
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
