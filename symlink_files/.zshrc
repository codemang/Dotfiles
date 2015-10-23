#!/usr/local/bin/zsh
#
export ZSH=/Users/codemang/.oh-my-zsh
export EDITOR="/Applications/MacVim.app/Contents/MacOS/Vim"
export ARCHFLAGS="-arch x86_64"
source "$ZSH/oh-my-zsh.sh"
setopt CORRECT

# Allow for vim mode in shell

# --------------------------------------------------------
#                TERMINAL PROMPT
# --------------------------------------------------------

autoload -U colors && colors

GOOD_EXIT_STATUS_COLOR=%F{154}
BAD_EXIT_STATUS_COLOR=%F{197}
WORKING_DIRECTORY_COLOR=%F{159}
GIT_BRANCH_COLOR=%F{213}

bindkey -v
bindkey kj vi-cmd-mode

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
  echo "$GIT_BRANCH_COLOR$(git_branch)%{$reset_color%}"
}

function tmux_session() {
  if $(command tmux ls | grep -q attach)
  then
    echo $(command tmux display-message -p '#S')
  else
    echo "ASDF"
  fi
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

function parse_git_dirty() {
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

vim_ins_mode=""
vim_cmd_mode="%F{221}[vim-mode] %{$reset_color%}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

# Fix a bug when you C-c in CMD mode and you'd be prompted with CMD mode indicator, while in fact you would be in INS mode
# Fixed by catching SIGINT (C-c), set vim_mode to INS and then repropagate the SIGINT, so if anything else depends on it, we will not break it
# Thanks Ron! (see comments)
function TRAPINT() {
  vim_mode=$vim_ins_mode
  return $(( 128 + $1 ))
}

PS1='
$(exit_status) $(working_directory) $(git_prompt) $(parse_git_dirty)$(up_stream)$(down_stream)${vim_mode}
$(arrow) '

zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=60

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
alias cob="git checkout -b"
alias cod="git branch -d"
alias codd="git branch -D"

# push
alias push="git push"
alias pusho="git push origin "

# pull
alias pull="git pull"
alias pullo="git pull origin"

# commit
alias cmt="git commit -am"
alias amend="git commit -a --amend --no-edit"
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
alias zpref="vim ~/.zshrc"
alias vtree="vim -c ':CommandT'"
alias vnerd="vim -c ':NERDTree'"
alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"

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
alias vprov="vagrant provision"

# TMUX
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tpref="vim ~/.tmux.conf"
alias tsource="tmux source-file /Users/codemang/.tmux.conf"
alias tls="tmux list-sessions"
alias ts="tmux switch -t"
alias td="tmux detach"
alias tk="tmux kill-session -t"

export LD_BIND_NOW=1
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_TRIGGER=',,'

source ~/.bin/tmuxinator.zsh

# Toggle between vim and shell with ctrl-z
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
