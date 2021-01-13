" Make sure to use bash shell
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/shared/nvim/plugged')

" GUI Enhancements
" Utility showing vim mode status, etc in lower bar
Plug 'vim-airline/vim-airline'
" Get Git integration for vim-airline
Plug 'tpope/vim-fugitive'
" Highlight yanked materials
Plug 'machakann/vim-highlightedyank'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" CoC
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Go support, see configs later
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Automatic autocompletion
" This has a tendency to break with new python3 installs/upgrades
" If broken, run :checkhealth
" May need to install nvim module to enable remote plugin updates, eg:
" python3 -m pip install --user --upgrade pynvim
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Vue support
Plug 'posva/vim-vue'

" Basic zig highlighting and file detection
" For ZLS support, go here: https://github.com/zigtools/zls#neovimvim8
Plug 'ziglang/zig.vim'

call plug#end()

""""""""""""""""""""""""""""""""""""""""""
" Editor Configuration Section
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

" Use custom python3 installation if necessary
if !empty($CUSTOM_PYTHON_LOC)
    let g:python3_host_prog=$CUSTOM_PYTHON_LOC
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap leader key because backslash is inconvenient
" Doing this in a roundabout way, normal mode only, to not get hang while
" typing
nmap <space> <bslash>

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
" Automatically turn on autocomplete for vim-go
autocmd FileType go call deoplete#enable()

" Languages and Environments
" Supported languages/environments:
" - Go
" - Vue

" Format - on save and with '<Leader>f'
" Go
autocmd FileType go nnoremap <Leader>f :GoFmt<CR>

" Go to definition - 'gd'
" Go - taken care of within 'vim-go'
autocmd FileType zig nmap gd <Plug>(coc-definition)

" Run tests - '<Leader>t'
" Go
autocmd FileType go nnoremap <Leader>t :GoTest<CR>





" LEGACY SECTION - (may not be up to date, left for rare cases it's needed)
" Search ctags, if applicable
autocmd FileType c,cpp nnoremap <Leader>' :Tags<CR>

" goto definition
autocmd FileType c,cpp nnoremap gd <c-]>

" Get function information
autocmd FileType c,cpp nnoremap <Leader><Space> :call LanguageClient#textDocument_hover()<CR>

" Import a given path in the current buffer in Go, via vim-go
autocmd FileType go nnoremap <Leader>i :GoImport<Space>
" Remove, inverse of the above
autocmd FileType go nnoremap <Leader>r :GoDrop<Space>
