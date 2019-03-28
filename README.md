Machine Provisioner
-------------------

This is a set of bootstrapping scripts, configuration files, and other assets
that bootstrap a new Macbook with all the Desktop applications, software
packages, and other tools I use daily.

## Installation and usage

For a first time installation
```
$ xcode-select --install
$ git clone https://github.com/codemang/Dotfiles.git
$ cd Dotfiles
$ rake setup
```

This requires your password at a few steps. Once this completes, you must...

* Restart your computer for certain configurations to take effect.
* Complete the manual steps.

### Manual Steps

1) Sign in to 1Password using the QR code from your phone

1) [Create new Github SSH keys](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) and [add it to your ssh config](https://www.keybits.net/post/automatically-use-correct-ssh-key-for-remote-git-repo/)

1) In order to push dotfiles in the future you need to switch the remote to the
SSH version

    ```
    $ git remote set-url origin git@github.com:codemang/Dotfiles.git
    ```

1) [Remap caps lock to control](https://stackoverflow.com/questions/127591/using-caps-lock-as-esc-in-mac-os-x/40254864#40254864)

1) Open spectacle manually and give it the permissions it needs.

1) Go to System Preferences => Keyboard => Shortcuts => Spotlight, and disable
hotkeys for spotlight

1) Open alfred and change hotkey to `cmd + space`

1) Configure Finder to include these favorites
    * Home Directory
    * Screenshots
    * Personal directory

1) Set iterm to load its preferences from the Dotfiles repo

1) Change the [next/previous tab shortcut
keys](https://superuser.com/questions/497526/how-to-customize-google-chrome-keyboard-shortcuts) for chrome

1) Signin to the Chrome browser so that extensions are synced

1) Install [token_manager](https://github.com/codemang/token_manager)

1) Create [github
token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)
to be used by the [Copy Commit To PR](https://github.com/codemang/Dotfiles/blob/master/util/copy_commit_to_pr.rb) script

1)  Run `$ token_manager add github_copy_commit_to_pr [GITHUB TOKEN]`

### Updates

From then on any changes to the repo will be applied by pulling the latest version and running update.

```
$ git fetch; git reset --hard origin/master
$ rake setup
```

Overview
--------

At a high level, this repo executes the following steps.

* Install system wide packages via brew and brew cask
* Installs a ruby version manager and the latest stable version of ruby
* Installs language specific packages through RubyGems and NPM
* Installs zsh packages that are not available via package managers
* Symlinks all dotfiles to their correct location
* Installs all vim plugins
* Configures OSX specific settings, such as key repeat speed

In the end, I have a fully bootstrapped dev enviornment. Here are a few of the
key tools that are bootstrapped.

#### Editing Tools
* Iterm 2
* Tmux
* Zsh
* Vim

#### Integrated add-ons/plugins
* Fzf
* Ag
* Docker
* Vagrant

#### Desktop Applications
* 1Password
* Google Chrome
* Firefox
* Slack
* Alfred
* Iterm 2
* Authy

#### Symlinked Dotfiles
* zshrc
* vimrc
* tmux.conf
* gitconfig
