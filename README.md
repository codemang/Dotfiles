Nate's Dotfiles
---------------

A simple rake task which downloads all my dotfiles, installs any dependencies, and symlinks them approriately. This will in the future be integrated with a script which installs any apps and binaries I use, to completely provision a new personal dev machine.

Installation
------------

1) Clone the repo
```
$ git clone https://github.com/codemang/Dotfiles.git
```

2) Run the task

The simplest way to run this is to navigate to the Dotfiles folder you just created and and run the rake command
```
$ cd ~/Dotfiles
$ rake
```

If you want you can specify a different path to the Dotfiles folder
```
$ rake path=/path/from/home/directory
```

If you want to develop and test this rake task, the following command will create a test-Dotfile directory in the home directroy
```
$ rake test
```
