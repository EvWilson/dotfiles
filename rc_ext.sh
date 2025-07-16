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
HOST_COLOR="01;35m"
PATH_COLOR="01;36m"
PS1='\[\033[$PATH_COLOR\]${PS1X}$(parse_git_branch)\[\033[00m\] '

# Adjust FZF to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files -g "!{.git,node_modules}/*"'

alias cdd='cd $(fd --type directory | fzf)'
alias n='nvim'
alias gimme='n $(fd . ~/Documents | fzf)'

alias ls='ls --color=auto'

alias epoch='date +%s'

assert_arglen() {
	local expected_count="$1"
	shift
	if [ "$#" -ne "$expected_count" ]; then
		local caller="${FUNCNAME[1]:-main}"
		echo "error: $caller requires exactly $expected_count argument(s), but got $#" >&2
		return 1
	fi
	return 0
}

# In existing tmux window, open preferred format and change all open windows to cwd
winme() {
	local CURR_DIR=`pwd`
	tmux split-window -h -l 33%
	cd $CURR_DIR
	tmux split-window -v -l 66% -b
	cd $CURR_DIR
	tmux select-pane -t 0
}

ports() {
	lsof -iTCP -sTCP:LISTEN -n -P | awk '{print $1, substr($0, index($0,$9))}'
}

neovim_update() {
	echo "Updating neovim dependencies..."
	nvim --headless "+Lazy! sync" +qa
}

gitup() {
	if [ $# -eq 0 ]; then
		local MSG="Update"
	else
		local MSG=$@
	fi
	git add -A && git commit -m "$MSG" && git push
}

isnum() {
	case $1 in
		''|*[!0-9]*) echo '' ;;
		*) echo 'isnum' ;;
	esac
}

nagger() {
	PERIOD=$1
	shift
	TEXT=$@
	sleep $PERIOD
	osascript -e "display notification \"${TEXT}\" with title \"Nag Me\""
}

nagme() {
	if (( $# < 2 )); then
		echo "Please supply a period (e.g. 10m, 5s), and then the text of your notification"
		return 1
	fi
	PERIOD=$1
	VALUE=$(echo $PERIOD | sed 's/.$//')
	shift
	TEXT=$@
	if [[ ! $(isnum $VALUE) ]]; then
		echo "Period value $VALUE does not appear to be a number"
		return 1
	fi
	if [[ "$PERIOD" == *m ]]; then
		VALUE=$(($VALUE * 60))
	elif [[ "$PERIOD" == *s ]]; then
		:
	else
		echo "Unknown period, specify a time in minutes or seconds. E.g.: 5s, 10m"
		return 1
	fi
	nagger $VALUE $TEXT & disown
}


cdme() {
	cd "$(fd -t d . ~/Documents | fzf --preview 'tree -L 1 {}')"
}

gitco() {(
	set -e
	local BRANCH=$(git branch | fzf)
	# Remove leading asterisk, as in case of currently active branch
	BRANCH="${BRANCH#\*}"
	git checkout $BRANCH
)}
