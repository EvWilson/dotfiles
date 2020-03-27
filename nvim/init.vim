" Make sure to use bash shell
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/shared/nvim/plugged')

" GUI Enhancements
" Utility showing vim mode status, etc in lower bar
Plug 'itchyny/lightline.vim'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'

" Fuzzy finder
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

"" Deoplete completion manager
"if has('nvim')
"  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"else
"  Plug 'Shougo/deoplete.nvim'
"  Plug 'roxma/nvim-yarp'
"  Plug 'roxma/vim-hug-neovim-rpc'
"endif
"" Golang Deoplete support
"Plug 'deoplete-plugins/deoplete-go', { 'do': 'make'}

" Go vim settings, see configs later
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Coc - trying it out
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Javascript
"Plug 'pangloss/vim-javascript'

" Python
" Formatting
"Plug 'psf/black'

" Rust support
" Completion
"Plug 'ncm2/ncm2-racer'
" Syntax
"Plug 'rust-lang/rust.vim'

" Vue support
Plug 'posva/vim-vue'

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

" Some servers may have issues with backup files (taken from coc.nvim README)
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Make searching case-sensitive only if caps are passed (similar to rg)
" (Must ignorecase before smartcase will apply)
set ignorecase
set smartcase

" Persistent undo (across vim sessions)
set undodir=~/.vimdid
set undofile

" Enhanced tab completion
set wildmenu

" Maintain this many lines of context while scrolling, if possible
set scrolloff=15

" Enable mouse to set cursor location
set mouse=a

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" 80 character line marking
set colorcolumn=80
highlight colorcolumn ctermbg=darkgray ctermfg=black

" Highlight extra whitespace for removal
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Code completion
"if has('nvim')
"    let g:deoplete#enable_at_startup = 1
"endif
"if !has('python3')
"endif

"" Allow for Go highlighting - vim-go
"let g:go_highlight_build_constraints = 1
"let g:go_highlight_extra_types = 1
"let g:go_highlight_fields = 1
"let g:go_highlight_functions = 1
"let g:go_highlight_methods = 1
"let g:go_highlight_operators = 1
"let g:go_highlight_structs = 1
"let g:go_highlight_types = 1
"
"" Only lint on save
"let g:ale_lint_in_text_changed = 'never'
"let g:ale_lint_on_insert_leave = 1
"let g:ale_lint_on_save = 1
"let g:ale_lint_on_enter = 1
"let g:ale_rust_rls_config = {
"	\ 'rust': {
"		\ 'all_targets': 1,
"		\ 'build_on_save': 1,
"		\ 'clippy_preference': 'on'
"	\ }
"	\ }
"let g:ale_linters = {
"    \ 'cpp': ['clangd'],
"    \ 'javascript': ['eslint'],
"    \ 'python': ['pylint', 'black'],
"    \ 'rust': ['rls'],
"    \ }
"highlight link ALEWarningSign Todo
"highlight link ALEErrorSign WarningMsg
"highlight link ALEVirtualTextWarning Todo
"highlight link ALEVirtualTextInfo Todo
"highlight link ALEVirtualTextError WarningMsg
"highlight ALEError guibg=None
"highlight ALEWarning guibg=None
"let g:ale_sign_error = \"X"
"let g:ale_sign_warning = \"!"
"let g:ale_sign_info = \"i"
"let g:ale_sign_hint = \"?"

" Autoformat rust code on save
let g:rustfmt_command = "rustfmt +nightly"
let g:rustfmt_autosave = 1
let g:rustfmt_fail_silently = 0

" Disable CSS preprocessors for Vue dev
let g:vue_pre_processors = []

" Use custom python3 installation if necessary
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

" Shortcut to delete current buffer
nnoremap <Leader>d :bd<CR>

"" Open NERDtree
"nnoremap <Leader>t :NERDTreeToggle<CR>

"" tab to select from autocomplete
"" and don't hijack my enter key
"inoremap <expr><Tab> (pumvisible()?(empty(v:completed_item)?"\<C-n>":"\<C-y>"):"\<Tab>")
"inoremap <expr><CR> (pumvisible()?(empty(v:completed_item)?"\<CR>\<CR>":"\<C-y>"):"\<CR>")

" START COC

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"


function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" Use `complete_info` if your (Neo)Vim version supports it.
"if has('patch8.1.1068')
"  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"else
"  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" END COC

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
"autocmd FileType python,rust nnoremap <silent> <Leader>d :ALEDetail<CR>

" goto definition
"autocmd FileType python,rust nnoremap gd :ALEGoToDefinition<CR>
autocmd FileType c,cpp nnoremap gd <c-]>

" Get function information
"autocmd FileType python,rust nnoremap <Leader><Space> :ALEHover<CR>
autocmd FileType c,cpp nnoremap <Leader><Space> :call LanguageClient#textDocument_hover()<CR>

" Import a given path in the current buffer in Go, via vim-go
autocmd FileType go nnoremap <Leader>i :GoImport<Space>
" Remove, inverse of the above
autocmd FileType go nnoremap <Leader>r :GoDrop<Space>
