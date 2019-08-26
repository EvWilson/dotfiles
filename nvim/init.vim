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
Plug 'dense-analysis/ale'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'
" NERDtree - visual file explorer
Plug 'scrooloose/nerdtree'
" Tagbar - visually display tags in a certain file, for C/C++ development
Plug 'majutsushi/tagbar'

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

" Go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Python
" Formatting
Plug 'psf/black'

" Rust support
" Completion
Plug 'ncm2/ncm2-racer'
" Syntax
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

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" Fixers
"let g:ale_fixers = {
"    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
"    \ }
" Linter
" Only lint on save
let g:ale_lint_in_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1
let g:ale_rust_rls_config = {
	\ 'rust': {
		\ 'all_targets': 1,
		\ 'build_on_save': 1,
		\ 'clippy_preference': 'on'
	\ }
	\ }
let g:ale_linters = {
    \ 'cpp': ['clangd'],
    \ 'python': ['pylint', 'black'],
    \ 'rust': ['rls'],
    \ }
highlight link ALEWarningSign Todo
highlight link ALEErrorSign WarningMsg
highlight link ALEVirtualTextWarning Todo
highlight link ALEVirtualTextInfo Todo
highlight link ALEVirtualTextError WarningMsg
highlight ALEError guibg=None
highlight ALEWarning guibg=None
let g:ale_sign_error = "X"
let g:ale_sign_warning = "!"
let g:ale_sign_info = "i"
let g:ale_sign_hint = "?"

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
nnoremap HH 0
nnoremap H ^
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

" Open Tagbar window
nnoremap <Leader>1 :TagbarToggle<CR>

" tab to select from autocomplete
" and don't hijack my enter key
inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

" Cycle buffers, using whatever I happen to have below
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprevious<CR>

" Open fzf commands
nnoremap <Leader>- :Files<CR>
nnoremap <Leader>= :Buffers<CR>
" This subsection is to make project ripgrep behave as expected
let g:rg_command = '
  \ rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "!{.git,node_modules,vendor}/*" '

command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
nnoremap <Leader>] :F<CR>

" Search ctags, if applicable
autocmd FileType c,cpp nnoremap <Leader>' :Tags<CR>

" Format on save
"autocmd BufWritePre *.py execute ':Black'

" Get ALE details
autocmd FileType python,rust nnoremap <silent> <Leader>d :ALEDetail<CR>

" goto definition
autocmd FileType python,rust nnoremap gd :ALEGoToDefinition<CR>
autocmd FileType c,cpp nnoremap gd <c-]>

" Get function information
autocmd FileType python,rust nnoremap <Leader><Space> :ALEHover<CR>
autocmd FileType c,cpp nnoremap <Leader><Space> :call LanguageClient#textDocument_hover()<CR>
