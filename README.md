Nate's Dotfiles
---------------

A simple rake task which downloads all my dotfiles, installs any dependencies, and symlinks them approriately. This will in the future be integrated with a script which installs any apps and binaries I use, to completely provision a development machine.

![Alt Text](https://github.com/codemang/Dotfiles/blob/master/recording.gif)

Installation
------------

For a first time installation
```
$ git clone https://github.com/codemang/Dotfiles.git
$ rake setup
$ source ~/.zshrc
$ rake update
```

From then on any changes to the repo will be applied by pulling the latest version and running update.

```
$ git fetch; git reset --hard origin/master
$ rake setup
```

## Manual Steps

1) Create new Github SSH keys

https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

2) Change the keyboard key repeat and key repeat delay speeds

3) Remap caps lock to control

https://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x/40254864#40254864

4) Open spectacle manually and give it the permissions it needs.

5) Change background image folder to the `desktop-images` folder

6) Configure Finder to include these favorites
* Home Directory
* Screenshots
* Personal directory

## Updating package list

```
```

Requirements/Dependencies
-----------

1. MacVim via Homebrew
1. CMake via homebrew (this is used by the You Complete Me Vim plugin)
1. Tmux via Homebrew
1. Tmuxinator via Gem

My Setup
--------

My development workflow is comprised of the following tools
* Iterm 2
* Tmux
* Zsh
* Vim

Integrated add-ons/plugins
* Fzf
* Ctags
* Ag
* Vim Plugins


General Process
--------

2. Install/update **homebrew** and all kegs/casks.

3. Install/update **zsh** and **oh-my-zsh**.

4. **Symlink** all files ending in `.sym` to the home directory.

5. Install/update all **Vim plugins**.

Work To Do
----------

0. Support Linux machines
0. Move already existing dotfiles to temporary location
0. Save logs to file
