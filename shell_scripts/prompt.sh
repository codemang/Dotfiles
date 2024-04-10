#!/bin/bash

function print_colors() {
  for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""
}

function light_prompt() {
  WORKING_DIRECTORY_COLOR="\033[01;35m"
  GOOD_EXIT_STATUS_COLOR="\033[32m"
  GIT_BRANCH_COLOR="\033[34m"
  ARROW_COLOR="\033[33m"
  BAD_EXIT_STATUS_COLOR="\033[32m"
  DIRTY_CHANGES="\033[31m"
  RESET_COLOR="\033[00m"
  WSL_COLOR="\033[01;36m"
}

light_prompt

# function dark_prompt() {
#   WORKING_DIRECTORY_COLOR=$fg[magenta]
#   GIT_BRANCH_COLOR=$fg[blue]
#   GOOD_EXIT_STATUS_COLOR=$fg[green]
#   BAD_EXIT_STATUS_COLOR=$fg[red]
#   ARROW_COLOR=$fg[yellow]
#   DIRTY_CHANGES=$fg[red]
# }

# --------------------------------------------------------
#                TERMINAL PROMPT
# --------------------------------------------------------

# Detect if git is initialized in this directory
function is_git_branch() {
  [[ -n "$(git status -s 2> /dev/null)" ]] && echo true
}

# Find the current git branch, if any
function git_branch() {
  echo "$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')"
}

# Show return code of last command
function exit_status(){
if [ $? -eq 0 ]
  then
     echo -e ''
  else
    echo -e "${BAD_EXIT_STATUS_COLOR}[${$?}]${NONE}"
  fi
}

# Show the current working directory
function working_directory() {
  # https://stackoverflow.com/a/25944070
  working_directory_with_tilda="${PWD/#$HOME/\~}"
  chome="/mnt/c/Users/nrubin19"
  working_directory_with_tilda="${working_directory_with_tilda/#$chome/\ch}"
  # echo "$WORKING_DIRECTORY_COLOR $working_directory_with_tilda $RESET_COLOR"
  printf "${WORKING_DIRECTORY_COLOR}$working_directory_with_tilda"
  # echo $working_directory_with_tilda
}


# Show the current git branch, if any
function git_prompt() {
  printf "$GIT_BRANCH_COLOR$(git_branch)"
}

# Show if there are upstream changes
function up_stream() {
  behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
  if [ $behind -gt 0 ]
  then
    echo "$ARROW_COLOR↑%{$reset_color%}"
  fi
}

# Show if there are downstream changes
function down_stream() {
  ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)

  if [ $ahead -gt 0 ]
  then
    echo "$ARROW_COLOR↓%{$reset_color%}"
  fi
}

function is_git_dirty() {
  $(git diff-index --quiet HEAD --) || echo true
}

# Show if there are changes to be committed.
function parse_git_dirty() {
  if [[ $(is_git_branch) == true ]] && [[ $(is_git_dirty) == true ]]; then
    printf "$DIRTY_CHANGES●"
  fi
}

# Show the orange arrows
function arrow() {
  printf "${ARROW_COLOR}❯❯❯"
}


# Show if currently in vim mode
vim_ins_mode=""
# vim_cmd_mode="%F{221}[vim-mode] %{$reset_color%}"
vim_cmd_mode="$fg[green][vim-mode] %{$reset_color%}"
vim_mode=$vim_ins_mode

# Fix a bug when you C-c in CMD mode and you'd be prompted with CMD mode
# indicator, while in fact you would be in INS mode Fixed by catching SIGINT
# (C-c), set vim_mode to INS and then repropagate the SIGINT, so if anything
# else depends on it, we will not break it Thanks Ron! (see comments)
function TRAPINT() {
  vim_mode=$vim_ins_mode
  return $(( 128 + $1 ))
}

function dir_with_optional_status() {
  if [ $? -eq 0 ]; then
    echo "$(working_directory)"
  else
    echo "$(exit_status) $(working_directory)"
  fi
}

reset_color() {
  printf "$RESET_COLOR"
}

wsl() {
    echo -ne "$WSL_COLOR[WSL]"
}

# Generate prompt
PS1='
$(dir_with_optional_status) $(wsl) $(git_prompt) $(parse_git_dirty)
$(arrow)$(reset_color) '
