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
