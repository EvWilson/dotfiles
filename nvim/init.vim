" Make sure to use bash over fish
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/shared/nvim/plugged')

" GUI Enhancements
" Utility showing vim mode status, etc in lower bar
Plug 'itchyny/lightline.vim'
" Asynchronous Lint Engine
Plug 'w0rp/ale'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'

" Automatic formatter
Plug 'Chiel92/vim-autoformat'

" Fuzzy finder
Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Semantic language support
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
" Completion plugins
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'
" C++
Plug 'ncm2/ncm2-pyclang'

call plug#end()


""""""""""""""""""""""""""""""""""""""""""
" Configuration Section
""""""""""""""""""""""""""""""""""""""""""
" Tabs to four spaces
set expandtab
set tabstop=4
set shiftwidth=4

" Show line numbers by default
set number

" Persistent undo (across vim sessions)
set undodir=~/.vimdid
set undofile

" Enhanced tab completion
set wildmenu

" Autoformat on save
"au BufWrite * :Autoformat

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" Required for operations modifying multiple buffers like rename.
set hidden

" EXPERIMENTAL
let g:python3_host_prog="/home/ewilson/.bin/mypy/bin/python3.7"

" path to directory where libclang.so can be found
"let g:ncm2_pyclang#library_path=$HOME."/.dotfiles/nvim/libclang.so"
"let BACKUP_LIBCLANG=${ls /usr/lib/x86_64-linux-gnu | grep -m 1 libclang}
let libclang_loc = system("ls /usr/lib/x86_64-linux-gnu | grep -m 1 libclang")
echom "Libclang loc: " . libclang_loc
let pyclang_libclang_loc=$PYCLANG_LIBCLANG_LOC
echom "Var: " . pyclang_libclang_loc 
if pyclang_libclang_loc
    echom "Found it"
    let g:ncm2_pyclang#library_path = system("echo $PYCLANG_LIBCLANG_LOC")
else
    echom "Could not find"
    let g:ncm2_pyclang#library_path = "/usr/lib/x86_64-linux-gnu/" . libclang_loc
endif
echom "Result: " . g:ncm2_pyclang#library_path

" Configure fixers for w0rp/ale plugin
let g:ale_fixers = {
            \'*': ['remove_trailing_lines', 'trim_whitespace'],
            \'c++': ['clang-tidy']
            \}
" Fix files on save, duh
"let g:ale_fix_on_save = 1

" Enforce highlighting scheme for Visual mode
"hi Visual guifg=White guibg=LightBlue gui=none

" Always be able to see at least 5 lines of context
set scrolloff=15

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable arrow keys for nav - use hjkl!
"noremap <Up> <Nop>
"noremap <Down> <Nop>
"noremap <Left> <Nop>
"noremap <Right> <Nop>

" Automatically close brackets, braces, quotes
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Use ; for commands
nnoremap ; :

" Use jj to escape quickly from insert mode
inoremap jj <ESC>

" Use CTRL-/ for next buffer
nnoremap <silent> gn :bnext<CR>
nnoremap <silent> gp :bprevious<CR>

" C++ goto definition
autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>
