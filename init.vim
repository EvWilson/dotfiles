" Make sure to use bash shell
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/share/nvim/plugged')

" GUI Enhancements
" Pretty lil gruvbox
Plug 'gruvbox-community/gruvbox'
" Utility showing vim mode status, etc in lower bar
Plug 'vim-airline/vim-airline'
" Get Git integration for vim-airline
Plug 'tpope/vim-fugitive'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'

" File explorer (Lua, requires neovim 0.6+ as of 2/17/2022)
Plug 'kyazdani42/nvim-web-devicons' " File icons for below
Plug 'kyazdani42/nvim-tree.lua'

" Beautiful QoL improvements from the illustrious tpope
" Cheatsheet:
"   - from within surrounded item, cs<thing to replace><replacement>
"   - from within surround, ds<thing to delete>
"   - surround line in quotes - yss"
"   - project page: https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'
" Cheatsheet: 'gc' from visual line mode to comment
Plug 'tpope/vim-commentary'

" Definition of custom text objects via kana/vim-textobj-user
Plug 'kana/vim-textobj-user'
" e.g. `cif{char}` for change in between arbitrary characters (`cif_` to
" change _phrase to change_)
Plug 'thinca/vim-textobj-between'
" e.g. `cij` for change between any brace pair
Plug 'Julian/vim-textobj-brace'
" My GFM helper :^) woot for first plugin
Plug 'EvWilson/gfmdoc'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Basic Zig highlighting and file detection
" For ZLS support, go here: https://github.com/zigtools/zls#neovimvim8
" Make sure CoC config is updated (:CocConfig)
Plug 'ziglang/zig.vim'

" Only conditionally load
if executable('go') == 1
    " All the lovely things you need to work with Go
    " Make sure CoC config is updated (:CocConfig) (snippet at https://github.com/neoclide/coc.nvim)
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
endif

call plug#end()

""""""""""""""""""""""""""""""""""""""""""
" Editor Settings Configuration Section
""""""""""""""""""""""""""""""""""""""""""
" WOOO COLORS
colorscheme gruvbox
set background=dark

" Default tabs to four spaces
set expandtab
set softtabstop=4
set tabstop=4
set shiftwidth=4

" Show line numbers in hybrid mode - show line you're on and the offset
" to surrounding lines
set number relativenumber

" Required for operations modifying multiple buffers like rename.
set hidden

" Some servers may have issues with backup files (taken from coc.nvim README)
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50

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

" Best of both worlds sign/number column
set signcolumn=yes

" Allow filtree viewer to set colors properly
set termguicolors

" 80 character line marking
set colorcolumn=80
highlight colorcolumn ctermbg=darkgray ctermfg=black

" Show me them beautiful spaces
set list
set listchars+=space:·

" A dirty hack to clear Markdown error highlighting completely, but I hated
" having underscores highlighted red, and would prefer to catch MD errors by
" watching a MD renderer anyway
hi link markdownError Normal

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings and Plugin Configuration Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap leader key because backslash is inconvenient
let mapleader = " "

" Automatically match brackets
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Use ; for commands
nnoremap ; :

" Clear highlighting from search
nnoremap <c-l> :noh<CR>

" Use below to escape from insert mode
inoremap jh <ESC>

" Easier line navigation, because the standard bindings for these keys suck
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" Make Y behave sanely
nnoremap Y yg_

" Yank to system clipboard easier
nnoremap <leader>y "+y
vnoremap <leader>y "+y

" Quicksave
nnoremap <leader>w :w<CR>

" Shortcut to delete current buffer
nnoremap <leader>d :bd<CR>

" Source RC file anytime
nnoremap <leader>sop :source ~/.config/nvim/init.vim<CR>

" Cycle buffers, using whatever I happen to have below
nnoremap <silent> <c-m> :bnext<CR>
nnoremap <silent> <c-n> :bprevious<CR>

" My GFM helpers
nnoremap <c-j> :GFMDUpNextList<CR>
nnoremap <c-k> :GFMDDownNextList<CR>
nnoremap <leader>tt :GFMDToggleTodo<CR>

" Open fzf commands
nnoremap <leader>h :Files<CR>
nnoremap <leader>j :Buffers<CR>
" This subsection is to make project ripgrep behave as expected when used as
" the backend to fzf
let g:rg_command = '
  \ rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
nnoremap <leader>k :F<CR>

" CoC-specific settings - leave mode as nmap, nnoremap doesn't work
" Navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" CoC autocomplete wrangling
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<c-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<c-p>" : "\<c-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<c-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Show open buffers in airline
let g:airline#extensions#tabline#enabled = 1

" Set up filetree viewer
function! s:setup_filetree()
lua << EOF
require'nvim-tree'.setup()
EOF
endfunction
call s:setup_filetree()
" Configure filetree hotkey functions
nnoremap <leader>u :NvimTreeToggle<CR>
nnoremap <leader>i :NvimTreeFindFile<CR>
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 1,
    \ 'files': 0,
    \ 'folder_arrows': 1,
    \ }
" Default will show icon by default if no icon is provided
let g:nvim_tree_icons = {
    \ 'symlink': '[link]',
    \ 'git': {
    \   'unstaged': "[unstaged]",
    \   'unmerged': "[unmerged]",
    \   'renamed': "[renamed]",
    \   'untracked': "[untracked]",
    \   'deleted': "[deleted]",
    \   'ignored': "[ignored]"
    \   },
    \ 'folder': {
    \   'arrow_open': "V",
    \   'arrow_closed': ">",
    \   }
    \ }

" Only open variables and stacktrace for Go debugging
" Cheatsheet:
" Start debug - :GoDebugStart
" Start debug with flags - :GoDebugStart . -someflag value
" Toggle breakpoint (can add line number) - :GoDebugBreakpoint <line_num>
" Continue to breakpoint - :GoDebugContinue
" Step execution (see help for differences) - :GoDebug[Next|Step|StepOver|StepOut]
" Print variable (shouldn't need often) - :GoDebugPrint <variable>
" Quit session - :GoDebugStop
" Check vim-go itself - :h vim-go
let g:go_debug_windows = {
      \ 'vars':       'rightbelow 60vnew',
      \ 'stack':      'rightbelow 10new',
\ }

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Language Configuration Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype css setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.json setlocal tabstop=2 shiftwidth=2 expandtab
