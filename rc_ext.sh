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

if [ -f ~/.local/shared/nvim/plugged/gruvbox/gruvbox_256palette.sh ]; then
    if [ $(uname) == "Darwin" ]; then
        . ~/.local/shared/nvim/plugged/gruvbox/gruvbox_256palette_osx.sh
    # This doesn't seem to work in Alacritty, which I usually use on Linux
    # Separate config function provided
    elif [ $(uname) == "Linux" ]; then
        # . ~/.local/shared/nvim/plugged/gruvbox/gruvbox_256palette.sh
        :
    else
        echo "Could not locate gruvbox theme to source into current shell"
    fi
fi

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
