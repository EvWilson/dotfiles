# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export $LS_COLORS

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
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!{.git,node_modules}/*"'
# Insert file from fzf into command
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
# Edit file from fzf
bind -x '"\C-p": nvim $(fzf);'
