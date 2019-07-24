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
"Plug 'Chiel92/vim-autoformat'

" LSP support
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

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
"Plug 'ncm2/ncm2-pyclang'

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

" Required for operations modifying multiple buffers like rename.
set hidden

" Persistent undo (across vim sessions)
set undodir=~/.vimdid
set undofile

" Enhanced tab completion
set wildmenu

" Always be able to see at least 5 lines of context
set scrolloff=15

" Check for various needed executables
if !executable('clangd')
    echom "You do not have clangd, needed for LanguageClient ops"
end

" Autoformat on save
"au BufWrite * :Autoformat

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" Set up LanguageClient
let g:LanguageClient_serverCommands = {
    \ 'cpp': ['clangd'],
    \ }

" Use custom python installation if necessary (pls, Mr. Sysadmin, I want to run my plugins)
if !empty($CUSTOM_PYTHON_LOC)
    let g:python3_host_prog=$CUSTOM_PYTHON_LOC
endif

" path to directory where libclang.so can be found (for ncm2-pyclang)
"let libclang_loc = system("ls /usr/lib/x86_64-linux-gnu | grep -m 1 libclang")
"if !empty($PYCLANG_LIBCLANG_LOC)
"    let g:ncm2_pyclang#library_path = $PYCLANG_LIBCLANG_LOC
"else
"    let g:ncm2_pyclang#library_path = "/usr/lib/x86_64-linux-gnu/" . libclang_loc
"endif

" Configure fixers for w0rp/ale plugin
"let g:ale_fixers = {
"            \'*': ['remove_trailing_lines', 'trim_whitespace'],
"            \'c++': ['clang']
"            \}
" Fix files on save, duh
"let g:ale_fix_on_save = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable arrow keys for nav - use hjkl!
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
"inoremap <Up> <Nop>
"inoremap <Down> <Nop>
"inoremap <Left> <Nop>
"inoremap <Right> <Nop>

" Automatically close brackets, braces, quotes
"inoremap " ""<left>
"inoremap ' ''<left>
"inoremap ( ()<left>
"inoremap [ []<left>
"inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Jump to the start and end of the line using the home row
"nnoremap H ^ 
nnoremap H 0
nnoremap L $

" Use ; for commands
nnoremap ; :

" Use jj to escape quickly from insert mode
inoremap jj <ESC>

" tab to select from autocomplete
" and don't hijack my enter key
inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

" Cycle buffers, using whatever I happen to have below
"nnoremap <silent> gn :bnext<CR>
"nnoremap <silent> gp :bprevious<CR>
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprevious<CR>

" Open fzf commands easily
nnoremap <Leader>- :Files<CR>
nnoremap <Leader>= :Buffers<CR>

" goto definition
"autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>
"nnoremap <silent> gd :ALEGoToDefinition<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
" Get function information
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR><Paste>
