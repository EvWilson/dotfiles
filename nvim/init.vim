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
" NERDtree - visual file explorer
Plug 'scrooloose/nerdtree'

" LSP support
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Fuzzy finder
"Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Semantic language support
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" Completion plugins
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-tmux'
Plug 'ncm2/ncm2-path'
" With Rust
Plug 'ncm2/ncm2-racer'

" Syntactic language support
Plug 'rust-lang/rust.vim'

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

" Enable mouse to set cursor location
set mouse=a

" Check for needed binaries
if !executable('fzf')
    echom "Install fzf to make your life better"
endif
if !executable('rg')
    echom "Install ripgrep to make your life better"
endif

" Check for CPP LSP
if !executable('clangd')
    echom "You do not have clangd, needed for LanguageClient ops"
endif

" Make sure we get what we need for Rust dev
if !executable('rls')
    echom "Make sure to install RLS and any others needed for Rust autocomplete!"
endif
if !executable('racer')
    echom "Make sure to install racer for Rust dev"
endif

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" Set up LanguageClient
let g:LanguageClient_serverCommands = {
    \ 'cpp': ['clangd'],
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ }

" Linter
" Only lint on save
let g:ale_lint_in_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1
let g:ale_linters = {'rust': ['rls']}
highlight link ALEWarningSign Todo
highlight link ALEErrorSign WarningMsg
highlight link ALEVirtualTextWarning Todo
highlight link ALEVirtualTextInfo Todo
highlight link ALEVirtualTextError WarningMsg
highlight ALEError guibg=None
highlight ALEWarning guibg=None
let g:ale_sign_error = "✖"
let g:ale_sign_warning = "⚠"
let g:ale_sign_info = "i"
let g:ale_sign_hint = "➤"

" Autoformat rust code on save
let g:rustfmt_command = "rustfmt +nightly"
let g:rustfmt_autosave = 1
let g:rustfmt_fail_silently = 0

" Use custom python installation if necessary (pls, Mr. Sysadmin, I want to run my plugins)
if !empty($CUSTOM_PYTHON_LOC)
    let g:python3_host_prog=$CUSTOM_PYTHON_LOC
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable arrow keys for nav - use hjkl!
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>

" Automatically match brackets
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Jump to the start and end of the line using the home row
nnoremap H 0
nnoremap L $

" Use ; for commands
nnoremap ; :

" Use jj to escape quickly from insert mode
inoremap jj <ESC>

" Quicksave
nnoremap <Leader>w :w<CR>
inoremap <Leader>w <c-o>:w<CR>

" Open NERDtree
nnoremap <Leader>t :NERDTreeToggle<CR>

" tab to select from autocomplete
" and don't hijack my enter key
inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

" Cycle buffers, using whatever I happen to have below
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprevious<CR>

" Open fzf commands easily
nnoremap <Leader>- :Files<CR>
nnoremap <Leader>= :Buffers<CR>
let g:rg_command = '
  \ rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "!{.git,node_modules,vendor}/*" '

command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
nnoremap <Leader>] :F<CR>

" Get ALE details easily
autocmd FileType rust nnoremap <silent> <Leader>d :ALEDetail<CR>

" goto definition
autocmd FileType rust nnoremap gd :ALEGoToDefinition<CR>
autocmd FileType c,cpp nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

" Get function information
autocmd FileType rust nnoremap <silent> <Leader><Space> :ALEHover<CR>
autocmd FileType c,cpp nnoremap <silent> <Leader><Space> :call LanguageClient#textDocument_hover()<CR>
