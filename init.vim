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

" Basic Zig highlighting and file detection
" For ZLS support, go here: https://github.com/zigtools/zls#neovimvim8
" Make sure CoC config is updated (:CocConfig)
Plug 'ziglang/zig.vim'

" Gate behind flag, because it's heavyweight
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

" Use below to escape from insert mode
inoremap jh <ESC>

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

" Languages
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd BufRead,BufNewFile *.json setlocal tabstop=2 shiftwidth=2 expandtab

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin Development Section (development to extract later)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <c-j> :call NextInList('down')<CR>
nnoremap <c-k> :call NextInList('up')<CR>
" Create the beginning of a new list item in whatever GitHub-flavored Markdown
" list construct you may be in
" Currently supports unordered lists and tasklists
function NextInList(direction)
    let l:debug = 0
    if a:direction != 'up' && a:direction != 'down'
        return
    endif
    let l:newitems = {
        \"list": " ",
        \"tasklist": " [ ] ",
        \}
    let l:inlist = ''
    " Find what list we're in
    let l:curline = getline('.')
    let l:leadchar = trim(curline)[0]
    if match(curline, '\v^\s*[\+\*-]\s\[[X ]\]') != -1
        let l:inlist = 'tasklist'
    elseif match(curline, '\v^\s*[\+\*-]\s') != -1
        let l:inlist = 'list'
    else
        if l:debug != 0
            echom 'Could not find matching list pattern for current line: "' . getline('.') . '"'
        endif
        return
    endif
    " Based on list we're in, and passed direction, create new list element
    " Match existing indent level
    let l:indent = indent('.')
    if a:direction == 'up'
        call append(line('.') - 1, repeat(' ', indent) . leadchar . newitems[inlist])
        norm! k$a
    else
        call append(line('.'), repeat(' ', indent) . leadchar . newitems[inlist])
        norm! j$a
    endif
endfunction

nnoremap <Leader>tt :call ToggleTodo()<CR>
" Toggles GitHub-flavored Markdown tasklist items on current line between
" complete/incomplete
function ToggleTodo()
    if matchstrpos(getline('.'), '- \[ \]')[1] != -1
        let l:newline = substitute(getline('.'), '- \[ \]', '- [X]', "g")
        call setline(line('.'), newline)
        return
    endif
    if matchstrpos(getline('.'), '- \[X\]')[1] != -1
        let l:newline = substitute(getline('.'), '- \[X\]', '- [ ]', "g")
        call setline(line('.'), newline)
        return
    endif
endfunction

nnoremap <Leader>tf :call WrapLine(80)<CR>
" Wraps all text lines in current Markdown buffer at specified width
function WrapLine(width)
    const l:save_cursor = getpos(".")
    const l:numlines = line('$')
    let l:lnum = 0
    let l:curline = ''
    let l:lines = []
    let l:inblock = 'f'
    " Iterate over lines, adding block statements to output unchanged, and
    " adding wrappable sections to buffer before processing and adding them
    while lnum < numlines
        let l:lnum += 1
        " Get the line and check if it seems to be in a block construct or not
        let l:line = getline(lnum)
        if match(trim(line), '\v^[^#>\-\|]+') != -1 || trim(line) == ''
            let l:inblock = 'f'
        else
            let l:inblock = 't'
        endif
        " If the line is blank, flush line buffer and add blank line
        if trim(line) == ''
            if len(curline)
                let l:lines += LineTextWrap(trim(curline), a:width)
                let l:curline = ''
            endif
            let l:lines += ['']
            continue
        endif
        " If in block, add line as-is. If not, add to line buffer.
        if inblock == 't'
            call add(lines, line)
        else
            let l:curline .= ' ' . line
        endif
    endwhile
    " Flush line buffer one last time
    if len(curline)
        let l:lines += LineTextWrap(trim(curline), a:width)
    endif
    " Output formatted lines
    let l:lnum = 1
    for line in lines
        call setline(lnum, line)
        let l:lnum += 1
    endfor
    " Delete any dangling lines
    " Silent incantation removes trailing blanks
    let l:lnum -= 1
    while l:lnum < l:numlines
        let l:lnum += 1
        call setline(lnum, '')
    endwhile
    silent! %s#\($\n\s*\)\+\%$##
    call setpos('.', save_cursor)
endfunction

function LineTextWrap(text, width)
    " If it's whitespace, just return an empty line
    if a:text == ''
        return ['']
    endif
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
    " If there's something in the trailing line, add it to result set
    if len(l:line)
        call add(lines, line)
    endif
    return l:lines
endfunction

nnoremap <Leader>tg :call FormatTable()<CR>
" Formats the table under the cursor, per GitHub-flavored MD spec
" Mostly just used to help with adjustments in spacing, prettiness
" To simplify this function, some assumptions are made:
"   - Each line contains exactly the necessary number of vertical bars
"   - Does not currently respect column justification
"   - Does not currently respect termination via following block structure
function FormatTable()
    let l:debug = 0
    const l:save_cursor = getpos('.')
    " Jump to second line (delim line) and make sure it seems sane
    norm! {jj
    let l:search_result = match(getline('.'), '\v^[\|:\- ]+$')
    if l:search_result == -1
        call setpos('.', save_cursor)
        if l:debug == 1
            echom 'Cursor does not appear to be on a table. Aborting.'
        endif
        return
    endif
    norm! k
    const l:startline = line('.')
    " Parse header line for number of fields and initial lengths
    let l:terms = []
    let l:curterms = []
    let l:max_widths = []
    let l:num_bars = count(getline(startline), '|')
    let l:header_items = split(trim(getline(startline)), '|')
    for item in header_items
        let l:trimmed = trim(item)
        call add(curterms, trimmed)
        call add(max_widths, len(trimmed))
    endfor
    call add(terms, curterms)
    " Process each line in table itself
    let l:line_num = startline + 2
    while 1
        let l:curterms = []
        " For current line, split up terms and add them to our buffer
        " Make sure to update max column width as we go
        let l:line_items = split(trim(getline(line_num)), '|', 1)[1:-2]
        if count(getline(line_num), '|') != num_bars
            if l:debug != 0
                echom 'Exiting loop, line items: ' . join(line_items, ' ') . ', headers: ' . join(header_items, ' ') . ', on line: ' . getline('.')
            endif
            break
        endif
        let l:item_idx = 0
        for item in line_items
            let l:trimmed = trim(item)
            call add(curterms, trimmed)
            if len(trimmed) > max_widths[item_idx]
                let l:max_widths[item_idx] = len(trimmed)
            endif
            let l:item_idx += 1
        endfor
        " Move to next line
        let l:line_num += 1
        call add(terms, curterms)
    endwhile
    " Output title line, then delim line, then each line of cells
    let l:line_num = startline
    let l:curline = ''
    let l:i = 0
    for word in terms[0]
        let l:curline .= '| ' . word . repeat(' ', max_widths[i] - len(word) + 1)
        let l:i += 1
    endfor
    let l:curline .= '|'
    call setline(line_num, curline)
    " Delim
    let l:line_num += 1
    let l:curline = '|'
    for width in max_widths
        let l:curline .= ' ' . repeat('-', width) . ' |'
    endfor
    call setline(line_num, curline)
    " Cells
    let l:terms = terms[1:-1]
    for words in terms
        let l:line_num += 1
        let l:curline = '|'
        let l:i = 0
        for width in max_widths
            let l:curline .= ' ' . words[i] . repeat(' ', width - len(words[i]) + 1) . '|'
            let l:i += 1
        endfor
        call setline(line_num, curline)
    endfor
    call setpos('.', save_cursor)
endfunction
