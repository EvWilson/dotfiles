# My wonderful little preferences, aliases, functions, etc, to make my shell feel like home
# Add this line to the end of .bashrc to load it in:
# [ -s "${HOME}/.dotfiles/bash/rc_ext.sh" ] && \. "${HOME}/.dotfiles/bash/rc_ext.sh"

# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export $LS_COLORS

# Function to auto-dial into a tmux session over SSH
# Usage: tsh <[username@]hostname> <tmux-session>
# Explanation:
# $1 is the hostname to pass in
# $2 is the tmux session to dial into
# -X to enable X11 forwarding
# -t launch tmux process interactively in pseudo-terminal
function tsh {
    host=$1
    session_name=$2
    if [ -z "$session_name" ]; then
        echo "Need to provide session-name. Example: tsh <hostname> <tmux-session>"
        return 1;
    fi
    ssh -X $host -t "tmux attach -t $session_name"
}

# Check for general needed dependencies
DEP_ARR=( rg fzf tmux )
for dep in "${DEP_ARR[@]}"
do
    [ -z $(command -v ${dep}) ] && echo "You should install ${dep} to make your life better"
done

# C++ dependencies
CPP_ARR=( clangd ctags )
for dep in "${CPP_ARR[@]}"
do
    [ -z $(command -v ${dep}) ] && echo "You should install ${dep} for CPP dev"
done

# Go dependencies
GO_ARR=( go )
for dep in "${GO_ARR[@]}"
do
    [ -z $(command -v ${dep}) ] && echo "You should install ${dep} for Go dev"
done

# Python dependencies
PYTHON_ARR=( python3 pip3 pylint black )
for dep in "${PYTHON_ARR[@]}"
do
    [ -z $(command -v ${dep}) ] && echo "You should install ${dep} for Python dev"
done

# Rust dependencies
RUST_ARR=( rls racer )
for dep in "${RUST_ARR[@]}"
do
    [ -z $(command -v ${dep}) ] && echo "You should install ${dep} for Rust dev"
done

# Set custom prompt
function abbreviated_pwd {
    ps_str=''
    pwd_str=$(pwd)
    if [ ! -z $(pwd | grep "^${HOME}") ]; then
        pwd_str=$(echo $pwd_str | sed "s#${HOME}#~#")
    fi
    OLD_IFS=$IFS
    IFS='/' # set delimiter
    read -ra ADDR <<< ${pwd_str} # pwd output is read into an array as tokens separated by IFS
    for i in "${ADDR[@]}"; do # access each element of array
        ps_str+="${i:0:1}/"
    done
    IFS=${OLD_IFS} # reset to default value after usage
    echo ${ps_str}
}
PS1='\[\e[1;32m\]\u@\h:\[\e[1;34m\]$(eval abbreviated_pwd)\[\e[0m\]$ '

# Adjust FZF to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files -g "!{.git,node_modules}/*"'
# Insert file from fzf into command
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
# Edit file from fzf
bind -x '"\C-p": nvim $(fzf);'
