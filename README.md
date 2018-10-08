Nate's Dotfiles
---------------

A simple rake task which downloads all my dotfiles, installs any dependencies, and symlinks them approriately. This will in the future be integrated with a script which installs any apps and binaries I use, to completely provision a development machine.

![Alt Text](https://github.com/codemang/Dotfiles/blob/master/recording.gif)

## Installation


For a first time installation
```
$ xcode-select --install
$ git clone https://github.com/codemang/Dotfiles.git
$ cd Dotfiles
$ rake setup
```

This requires your password at a few steps. Once this completes, you must
restart your computer for certain configurations to take effect. Once you
restart your computer, complete the manual steps.

## Updates

From then on any changes to the repo will be applied by pulling the latest version and running update.

```
$ git fetch; git reset --hard origin/master
$ rake setup
```

## Manual Steps

1) Sign in to 1Password from your phone

1) Create new Github SSH keys and add it to your ssh config

**Keys**
https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

**Config**
https://www.keybits.net/post/automatically-use-correct-ssh-key-for-remote-git-repo/

1) In order to push dotfiles in the future you need to switch the remote to the
SSH version

```
$ git remote set-url origin git@github.com:codemang/Dotfiles.git
```

1) Change the keyboard key repeat and key repeat delay speeds

1) Remap caps lock to control

https://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x/40254864#40254864

1) Open spectacle manually and give it the permissions it needs.

1) Go to System Preferences => Keyboard => Shortcuts => Spotlight, and disable

1) Open alfred and change hotkey to cmd + space

1) Configure Finder to include these favorites
* Home Directory
* Screenshots
* Personal directory

1) Set iterm to load its preferences from the Dotfiles repo

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
