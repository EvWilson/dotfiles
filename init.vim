" Make sure to use bash shell
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/shared/nvim/plugged')

" GUI Enhancements
" Pretty lil gruvbox
Plug 'morhetz/gruvbox'
" Utility showing vim mode status, etc in lower bar
Plug 'vim-airline/vim-airline'
" Get Git integration for vim-airline
Plug 'tpope/vim-fugitive'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'

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
" e.g. `cil` for change in line
Plug 'kana/vim-textobj-line'
" e.g. `cie` for change in entire buffer
Plug 'kana/vim-textobj-entire'
" e.g. `cii` for change in indent level
Plug 'kana/vim-textobj-indent'
" e.g. `cif{char}` for change in between arbitrary characters (`cif_` to
" change _phrase to change_)
Plug 'thinca/vim-textobj-between'
" e.g. `cij` for change between any brace pair
Plug 'Julian/vim-textobj-brace'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

if $ZIG_ENABLE == "1"
    " Basic Zig highlighting and file detection
    " For ZLS support, go here: https://github.com/zigtools/zls#neovimvim8
    " Make sure CoC config is updated (:CocConfig)
    Plug 'ziglang/zig.vim'
endif

if $GO_ENABLE == "1"
    " All the lovely things you need to work with Go
    " Make sure CoC config is updated (:CocConfig) (snippet at https://github.com/neoclide/coc.nvim)
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
endif

call plug#end()

""""""""""""""""""""""""""""""""""""""""""
" Editor Configuration Section
""""""""""""""""""""""""""""""""""""""""""
" WOOO COLORS
colorscheme gruvbox
set background=dark

" Tabs to four spaces
set expandtab
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

" Give more space for displaying messages.
set cmdheight=2

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

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
" TODO: replace yes with number once neovim 5.0 lands in package mgrs
set signcolumn=yes

" 80 character line marking
set colorcolumn=80
highlight colorcolumn ctermbg=darkgray ctermfg=black

" Highlight extra whitespace for removal
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Highlight tabs as errors.
match Error /\t/

" A dirty hack to clear Markdown error highlighting completely, but I hated
" having underscores highlighted red, and would prefer to catch MD errors by
" watching a MD renderer anyway
hi link markdownError Normal

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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap leader key because backslash is inconvenient
let mapleader = " "

" Disable arrow keys for nav - use hjkl!
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>

" Automatically match brackets
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Use ; for commands
nnoremap ; :

" Clear highlighting from search
nnoremap <C-l> :noh<CR>

" Use jj to escape from insert mode
" Use kk to escape and save from insert mode
inoremap jj <ESC>
inoremap kk <ESC>:w<CR>

" Easier line navigation, because the standard bindings for these keys suck
nnoremap H ^
nnoremap L $

" Make Y behave sanely
nnoremap Y yg_

" cn and cN now replace word under cursor and move to the next - spam . to
" search and replace after at lightning speeds
nnoremap cn *``cgn
nnoremap cN *``cgN

" Quicksave
nnoremap <Leader>w :w<CR>

" Shortcut to delete current buffer
nnoremap <Leader>d :bd<CR>

" Source RC file anytime
nnoremap <Leader>sop :source ~/.config/nvim/init.vim<CR>

" Cycle buffers, using whatever I happen to have below
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprevious<CR>

" Search for visually selected text with //
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" Open fzf commands
nnoremap <Leader>h :Files<CR>
nnoremap <Leader>j :Buffers<CR>
" This subsection is to make project ripgrep behave as expected when used as
" the backend to fzf
let g:rg_command = '
  \ rg --column --line-number --no-heading --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "!{.git,node_modules,vendor}/*" '
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
nnoremap <Leader>k :F<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin/Language Configuration Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
" Show open buffers in airline
let g:airline#extensions#tabline#enabled = 1
