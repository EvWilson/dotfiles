" Make sure to use bash shell
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""
" Plugin Section
""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.local/shared/nvim/plugged')

" GUI Enhancements
" Pretty lil gruvbox
Plug 'gruvbox-community/gruvbox'
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
inoremap jh <ESC>
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

" Exit shortcut
nnoremap <Leader>q :q<CR>

" Source RC file anytime
nnoremap <Leader>sop :source ~/.config/nvim/init.vim<CR>

" Cycle buffers, using whatever I happen to have below
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprevious<CR>
nnoremap <silent> <C-m> :bnext<CR>
nnoremap <silent> <C-n> :bprevious<CR>

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

" CoC autocomplete wrangling
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
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin/Language Configuration Section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
" Show open buffers in airline
let g:airline#extensions#tabline#enabled = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Development Section (development to extract later)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" my little todo list helpers
nnoremap <Leader>tn o[ ]
nnoremap <Leader>tt :call ToggleTodo()<CR>
function ToggleTodo()
    if matchstrpos(getline('.'), '\[ \]')[1] != -1
        let l:newline=substitute(getline('.'), '\[ \]', '[X]', "g")
        call setline(line('.'), newline)
        return
    endif
    if matchstrpos(getline('.'), '\[X\]')[1] != -1
        let l:newline=substitute(getline('.'), '\[X\]', '[ ]', "g")
        call setline(line('.'), newline)
        return
    endif
endfunction

nnoremap <Leader>tf :call WrapLine(80, 4)<CR>
function WrapLine(width, indent)
    " Set up loop control and output variables
    const l:numlines = line('$')
    let l:lnum = 0
    let l:lines = []
    let l:remainder = ''
    while l:lnum < l:numlines
        let l:lnum += 1
        let l:insert_newline = getline(lnum) == '' ? 'true' : ''
        let l:new_lines = LineTextWrap(remainder . getline(lnum), a:width, a:indent, insert_newline)
        let l:remainder = ''
        if len(new_lines) > 1 && new_lines[-1] != ''
            let l:remainder = new_lines[-1]
            let l:new_lines = new_lines[0:-2]
        endif
        let l:lines = lines + new_lines
    endwhile
    if len(remainder)
        call add(lines, remainder)
    endif
    " Now have appropriately-wrapped lines, just need to write them out
    let l:lnum = 0
    for new_line in lines
        let l:lnum += 1
        call setline(lnum, new_line)
    endfor
endfunction

function LineTextWrap(text, width, indent, insert_newline)
    let l:lines = []
    let l:line = ''
    " For each word in the line
    for word in split(a:text)
        " If the line would be too long, add it to result set and reset line
        if len(line) + len(word) + 1 > a:width
            call add(lines, line)
            let l:line = ''
        endif
        " Add space between words
        if len(l:line)
            let l:line .= ' '
        endif
        let l:line .= word
    endfor
    if len(l:line)
        call add(lines, line)
    endif
    if a:insert_newline == 'true'
        call add(lines, '')
    endif
    return l:lines
endfunction
