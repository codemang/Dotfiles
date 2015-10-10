syntax on 
let mapleader="-"
set background=dark
colorscheme solarized


set expandtab
set tabstop=2
set shiftwidth=2
set number
set hlsearch
set nocompatible              
set wrap
set laststatus=2
set t_Co=256

" Make tildas invisible below code
highlight NonText ctermfg=0

" Color left column
highlight LineNr ctermfg=161 ctermbg=0

let &t_SI = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

filetype off                 

" Vim Plug Section
call plug#begin('~/.vim/plugged')


" Auto Complete/Suggestions
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" Close braces, brackets, etc
Plug 'tpope/vim-endwise'


Plug 'Raimondi/delimitMate'

" Comment big chunks of code
Plug 'tComment'
  " gc: Comment highlighted section
  " gcc: Comment current line

Plug 'kien/ctrlp.vim'

" Navigate file system
Plug 'scrooloose/nerdtree'

" Show file name, other info
Plug 'bling/vim-airline'

" Helpful navigation
Plug 'easymotion/vim-easymotion'

Plug 'rking/ag.vim'

" Syntax highlighting for ansible
Plug 'pearofducks/ansible-vim'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'


call plug#end()


" --------------------------------------------
"          Custom Mappings 
" --------------------------------------------

map <Leader>s :source ~/.vimrc <CR>     " Reload vimrc 
map <Leader>w :w <CR>                   " Save file 
map <Leader>q :q <CR>                   " Close file
map <Leader>wq :wq <CR>                 " Save and close file
map <Leader>j :e # <CR>                 " Toggle between last opened file
map <Leader>h :noh <CR>                 " Remove highlighted words from search


" ADD NEW MAPPING FOR SWITCHING PANES

" Insert lines before/above sections and stay in normal mode
map <Space>] O<Esc>
map <Space>[ o<Esc>

" NERD Tree mappings
map <Leader>nn :NERDTree <CR>
map <Leader>n :NERDTree 
map <Leader>nb :NERDTreeFromBookmark 
map <Leader>nt :NERDTreeToggle <CR>
map <Leader>nm :NERDTreeMirror <CR>
map <Leader>nw :NERDTreeCWD <CR>
map <Leader>nc :NERDTreeFind <CR>

" FZF
map <Leader>t :FZF <CR>

let g:ruby_path = system('/usr/bin/ruby')
" set re=1

" let g:ackprg = 'ag --nogroup --nocolor --column'

let g:NERDTreeWinSize = 40
" let g:ansible_extra_syntaxes = "/usr/share/vim/vim73/syntax/sh.vim /usr/share/vim/vim73/syntax/ruby.vim"
