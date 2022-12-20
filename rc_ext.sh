# My wonderful little preferences, aliases, functions, etc, to make my shell feel like home
# Add this line to the end of .bashrc to load it in:
# [ -s "${HOME}/.dotfiles/rc_ext.sh" ] && \. "${HOME}/.dotfiles/rc_ext.sh"

# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export $LS_COLORS

# Set custom prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
PROMPT_COMMAND='PS1X=$(p="${PWD#${HOME}}"; [ "${PWD}" != "${p}" ] && printf "~";IFS=/; for q in ${p:1}; do printf /${q:0:1}; done; printf "${q:1}")'
PS1='\[\033[01;33m\]\u\[\033[00m\]:\[\033[01;31m\]${PS1X}$(parse_git_branch)\[\033[00m\] '

# Adjust FZF to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files -g "!{.git,node_modules}/*"'

alias cdd='cd $(fd --type directory | fzf)'
alias n='nvim'
alias gch='git checkout'

if [ $(uname) == "Linux" ]; then
    alias ls='ls --color=auto'
fi

# In existing tmux window, open preferred format and change all open windows to cwd
winme() {
    local CURR_DIR=`pwd`
    tmux split-window -h -p 33
    cd $CURR_DIR
    tmux split-window -v -p 66 -b
    cd $CURR_DIR
    tmux select-pane -t 0
}

neovim_update() {
    echo "Updating neovim dependencies..."
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

gitup() {
    if [ $# -eq 0 ]; then
        local MSG="Update"
    else
        local MSG=$@
    fi
    git add -A && git commit -m "$MSG" && git push
}
