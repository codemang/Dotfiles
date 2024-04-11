source ~/Dotfiles/shell_scripts/git.sh
source ~/Dotfiles/shell_scripts/tmux.sh
source ~/Dotfiles/shell_scripts/notes.sh
source ~/Dotfiles/shell_scripts/fzf.sh
source ~/Dotfiles/shell_scripts/z.sh
source ~/Dotfiles/shell_scripts/docker.sh
source ~/Dotfiles/shell_scripts/prompt.sh
source ~/Dotfiles/shell_scripts/vim.sh
source ~/Dotfiles/shell_scripts/misc.sh
source ~/Dotfiles/shell_scripts/ruby.sh
source ~/Dotfiles/shell_scripts/wsl_misc.sh

lsync_dir() {
  folder=${PWD##*/}
  lsyncd -nodaemon -delay 1 -rsyncssh $PWD nrubin19@tscgwd-rr-880 /home/nrubin19/$folder
}

tdev() {
  mux start dev $*
}

pbv() {
  win32yank.exe -o --lf
}

view_csv() {
  cat $1 | sed 's/,/ ,/g' | column -t -s, | less -S
}
