Nate's Dotfiles
---------------

A simple rake task which downloads all my dotfiles, installs any dependencies, and symlinks them approriately. This will in the future be integrated with a script which installs any apps and binaries I use, to completely provision a development machine.

Installation
------------

```
$ cd /path/to/dotfile/parent
$ git clone https://github.com/codemang/Dotfiles.git
$ rake
```


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
* Vim  Plugins


Pipeline
--------

1. Update the Dotfiles repo. This just pulls the latest version from Github. 

2. Install/update **homebrew**. When the native ruby installation is broken this task will fail, and so the entire installation process will be aborted.

3. Install/update **zsh**. This includes oh-my-zsh.

4. **Symlink** all the dotfiles to the home directory.

5. Install all **Vim plugins**. This is accomplished by opening Vim and running `:PlugInstall`.

6. Source the **.zshrc** file.


Work To Do
----------

0. Move already existing dotfiles to temporary location
0. Support Linux machines
0. Color output
0. Save logs to file
0. Break up `.zshrc` into separate files
0. Expand `.vimrc` customizations
0. Decide if the `.oh-my-zsh` and `.vim` directories should be tracked.
