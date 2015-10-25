" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|
" *                                                                    *
" |                            Nates Vimrc                             |
" *                                                                    *
" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|


" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|
"                                 Plugins
" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|

call plug#begin('~/.vim/plugged')

" Auto Complete/Suggestions
" Needs CMake via Homebrew
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" Adds endif in ruby
Plug 'tpope/vim-endwise'

" Close braces, brackets, etc
Plug 'Raimondi/delimitMate'

" Comment big chunks of code
Plug 'tComment'

" Navigate file system
Plug 'scrooloose/nerdtree'

" Show file name, other info
Plug 'bling/vim-airline'

" Helpful navigation
Plug 'easymotion/vim-easymotion'

" Search project
" Needs Silver Surfer via Homebrew
Plug 'rking/ag.vim'

" Syntax highlighting for ansible
Plug 'pearofducks/ansible-vim'

" Syntax highlighting for ansible
Plug 'Glench/Vim-Jinja2-Syntax'

" Undo tree
Plug 'sjl/gundo.vim'

" Use git commands in vim
Plug 'tpope/vim-fugitive'

" Markdown in vim
Plug 'godlygeek/tabular'

" Markdown in vim
Plug 'plasticboy/vim-markdown'

" Make a comment to Github from vim
Plug 'mmozuras/vim-github-comment'

" Use the Github API in vim, works with github comment
Plug 'mattn/webapi-vim'

" Fuzzy finder
" Needs FZF via Homebrew
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" Navigate tmux/vim panes the same way
" Needs tmux via Homebrew
Plug 'christoomey/vim-tmux-navigator'

" Autogenerate ctags
" Needs Ctags via Homebrew
Plug 'szw/vim-tags'

" Show git diff marks in vim
Plug 'airblade/vim-gitgutter'

Plug 'benmills/vimux'

call plug#end()



" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|
"                                 Custom Vim Settings
" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|

syntax on

let mapleader=","                                " Set my leader to '-'
let &t_SI = "\<Esc>]50;CursorShape=2\x7"         " Underscore in insert mode
let &t_EI = "\<Esc>]50;CursorShape=0\x7"         " Solid block in other modes
let @/=''                                        " Empty search register so sourcing doesn't highlight
let g:ruby_path = system('/usr/bin/ruby')        " Improve ruby speed

colorscheme solarized

filetype plugin indent on

set background=dark
set number                                       " Show line numbers
set shortmess=atI                                " No welcome message
set re=1                                         " Improve ruby speed
set t_Co=256                                     " Set vim to use 256 colors
set laststatus=2                                 " Always show vim-airline status
set encoding=utf-8
set splitbelow
set splitright
set noerrorbells visualbell t_vb=

set expandtab                                    " Make tab into spaces
set tabstop=2                                    " Set tab width to 2 spaces
set shiftwidth=2                                 " Make <,> tab use 2 spaces
set autoindent                                           " Auto indent
set smartindent                                           " Smart indent
set smarttab

set hlsearch                                     " Highlight search results
set incsearch                                    " Search as characters are entered
set ignorecase                                   " Ignore case when searching
set smartcase                                    " Unless capital letter

set scrolloff=3                                  " Keep 5 rows beneath cursor when scrolling
set sidescrolloff=15

set wildmenu
set wildmode=full

set noswapfile
set nobackup
set nowb

hi StatusLine ctermbg=white ctermfg=black
hi WildMenu ctermbg=black ctermfg=white

highlight NonText ctermfg=0                      " Make tildas invisible below code
highlight LineNr ctermfg=161 ctermbg=0           " Color left column



" --------------------- To consider ---------------------
" set lazyredraw
" copy to clipboard
" no swp files
" nnoremap j gj
" nnoremap k gk
" set ttyfast
" set gdefault
" set autoread                    "Reload files changed outside vim



" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|
"                                 Custom Vim Mappings
" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|

" Remap escape to fd
inoremap kj <Esc>
inoremap <esc> <nop>

nmap <Leader>v :e ~/.vimrc<CR>
nmap <Leader>s :source ~/.vimrc<CR>
nmap <Leader>w :w<CR>
nmap <Leader>e :e
nmap <Leader>q :q<CR>
nmap <Leader>wq :wq<CR>
nmap <Leader>j :e #<CR>
nmap <Leader>h :noh<CR>
nmap <Space>] Okj
nmap <Space>[ okj

" Switch panes without 'w'
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Toggle spell check
nmap <Leader>ss :setlocal spell! spelllang=en_us<CR> " Toggle spellcheck

" Strip trailing whitespace and end of file new lines
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)

  let save_cursor = getpos(".")
  :silent!:%s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
nmap <Leader>sw :call StripWhitespace()<CR>

 " Allow saving with sudo permission.
function! SudoSaveFile()
  exec 'silent :w !sudo tee > /dev/null %'
endfunction
command! SudoSave call SudoSaveFile()


" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|
"                      Custom Plugin Settings And Mappings
" |-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*|

" ------------------------------- NERD Tree ----------------------------
let g:NERDTreeWinSize = 40

nmap <Leader>nn :NERDTree <CR>
nmap <Leader>n :NERDTree
nmap <Leader>nb :NERDTreeFromBookmark
nmap <Leader>nt :NERDTreeToggle <CR>
nmap <Leader>nm :NERDTreeMirror <CR>
nmap <Leader>nw :NERDTreeCWD <CR>
nmap <Leader>nc :NERDTreeFind <CR>

" ----------------------------- GitHub Comment -------------------------
nmap <Leader>ghc :GHComment
let g:github_user = 'codemang'


" ------------------------------- FZF ----------------------------------
nmap <Leader>t :FZF <CR>


" ------------------------------- Ansible Vim --------------------------
let g:ansible_extra_syntaxes = "/usr/share/vim/vim73/syntax/sh.vim /usr/share/vim/vim73/syntax/ruby.vim"


" ------------------------------- Ag Vim -------------------------------
nmap <leader>a :Ag
let g:ag_highlight=1


" ------------------------------- Vim Markdown -------------------------
let g:vim_markdown_folding_disabled=1


" ------------------------------- Gundo --------------------------------
nnoremap <leader>u :GundoToggle<CR>


" ------------------------------- Airline Vim --------------------------
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_section_z=''

" ------------------------------- Git GUtter ---------------------------
command GutSign execute "GitGutterSignsToggle"

map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vl :VimuxRunLastCommand<CR>
let VimuxUseNearest = 0





