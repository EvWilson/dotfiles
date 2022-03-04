# My wonderful little preferences, aliases, functions, etc, to make my shell feel like home
# Add this line to the end of .bashrc to load it in:
# [ -s "${HOME}/.dotfiles/rc_ext.sh" ] && \. "${HOME}/.dotfiles/rc_ext.sh"

# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export $LS_COLORS

# Set custom prompt
PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
PS1='\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;31m\]${PS1X}\[\033[00m\] '

# Adjust FZF to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files -g "!{.git,node_modules}/*"'

alias cdd='cd $(fd --type directory | fzf)'
alias n='nvim'

if [ $(uname) == "Linux" ]; then
    alias ls='ls --color=auto'
fi

# In existing tmux window, open preferred format and change all open windows to cwd
function winme {
    CURR_DIR=`pwd`
    tmux split-window -h -p 33
    cd $CURR_DIR
    tmux split-window -v -p 66 -b
    cd $CURR_DIR
    tmux select-pane -t 0
}

# History fuzzy-find shortcut
function hist {
    $(history | sed -e 's/^\ \w*\ \w* //' | fzf)
}
