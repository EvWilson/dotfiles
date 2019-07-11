

" Disable arrow keys for nav - use hjkl!
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Automatically close brackets, braces, quotes
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Tabs to four spaces
set expandtab
set tabstop=4
set shiftwidth=4

" Use ; for commands
nnoremap ; :

" Use jj to escape quickly from insert mode
imap jj <ESC>

" Show line numbers by default
set number

" Persistent undo (across vim sessions)
set undodir=~/.vimdid
set undofile

" Enhanced tab completion
set wildmenu

" Use CTRL-/ for next buffer
nnoremap <silent> gn :bnext<CR>
nnoremap <silent> gp :bprevious<CR>

" Autoformat on save
au BufWrite * :Autoformat

" Plugin section
call plug#begin('~/.local/share/nvim/plugged')

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
Plug 'autozimu/LanguageClient-neovim', {
            \ 'branch': 'next',
            \ 'do': 'bash install.sh',
            \ }
" Autocomplete
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
" Enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect
" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
" General completion
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-tmux'
" Rust
Plug 'ncm2/ncm2-racer'
" C/C++
Plug 'ncm2/ncm2-pyclang'

call plug#end()

" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
            \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
            \ }

nnoremap <F5> :call LanguageClient_contextMenu()<CR>

" Set directory of libclang for use by ncm2/ncm2-pyclang
let g:ncm2_pyclang#library_path = '/usr/lib/x86_64-linux-gnu/libclang-8.so.1'
" Configure fixers for w0rp/ale plugin
let g:ale_fixers = {
            \'*': ['remove_trailing_lines', 'trim_whitespace'],
            \'c++': ['clang-tidy']
            \}
" Fix files on save, duh
let g:ale_fix_on_save = 1
