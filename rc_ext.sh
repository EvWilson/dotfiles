# My wonderful little preferences, aliases, functions, etc, to make my shell feel like home
# Add this line to the end of .bashrc to load it in:
# [ -s "${HOME}/.dotfiles/rc_ext.sh" ] && \. "${HOME}/.dotfiles/rc_ext.sh"

# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export $LS_COLORS

# Set custom prompt
PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]${PS1X}\[\033[00m\] '

# Adjust FZF to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files -g "!{.git,node_modules}/*"'

alias cdd='cd $(fd --type directory | fzf)'
alias n='nvim'

if [ $(uname) == "Linux" ]; then
    alias ls='ls --color=auto'
fi

# In existing tmux window, open preferred format and change all open windows to cwd
function winhere {
    CURR_DIR=`pwd`
    tmux split-window -h -p 33
    cd $CURR_DIR
    tmux split-window -v -p 33
    cd $CURR_DIR
    tmux select-pane -t 0
}

# Source shortcut
function sourceme {
    source ~/.bashrc
}

# History fuzzy-find shortcut
function hist {
    $(history | sed -e 's/^\ \w*\ \w* //' | fzf)
}

# Adds gruvbox coloring to Alacritty
function color_alacritty {
    mkdir -p ~/.config/alacritty
    touch ~/.config/alacritty/alacritty.yml
    cat >> ~/.config/alacritty/alacritty.yml << EOF
# Colors (Gruvbox dark)
colors:
  # Default colors
  primary:
    # hard contrast: background = '0x1d2021'
    background: '0x282828'
    # soft contrast: background = '0x32302f'
    foreground: '0xebdbb2'

  # Normal colors
  normal:
    black:   '0x282828'
    red:     '0xcc241d'
    green:   '0x98971a'
    yellow:  '0xd79921'
    blue:    '0x458588'
    magenta: '0xb16286'
    cyan:    '0x689d6a'
    white:   '0xa89984'

  # Bright colors
  bright:
    black:   '0x928374'
    red:     '0xfb4934'
    green:   '0xb8bb26'
    yellow:  '0xfabd2f'
    blue:    '0x83a598'
    magenta: '0xd3869b'
    cyan:    '0x8ec07c'
    white:   '0xebdbb2'
EOF
}

# Downloads iterm gruvbox theme and saves to the gruvbox plugin dir, prints help info for next steps
function color_iterm {
    THEME_LOC="~/.local/shared/nvim/plugged/gruvbox/gruvbox.itermcolors"
    curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Gruvbox%20Dark.itermcolors -o $THEME_LOC
    echo "In iTerm, hit Cmd+i, go to colors, import from $THEME_LOC, set new color preference"
}
