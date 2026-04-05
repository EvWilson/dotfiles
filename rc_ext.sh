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

alias n='nvim'

alias ls='ls --color=auto'

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


gitco() {(
	set -e
	local BRANCH=$(git branch | fzf)
	# Remove leading asterisk, as in case of currently active branch
	BRANCH="${BRANCH#\*}"
	git checkout $BRANCH
)}

# Git worktree helpers

# Create a new worktree and cd into it.
# Usage: wt-new <branch-name> [base-branch]
#   base-branch defaults to main
wt-new() {
	local branch="${1:?Usage: wt-new <branch-name> [base-branch]}"
	local base="${2:-main}"
	local repo_root
	repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repo"; return 1; }
	local worktree_path="${repo_root}/../$(basename "$repo_root")-${branch}"
	git worktree add -b "$branch" "$worktree_path" "$base" || return 1
	cd "$worktree_path"
}

# Switch to an existing worktree via fzf.
# Usage: wt-pick
wt-pick() {
	local selection
	selection=$(git worktree list 2>/dev/null \
		| fzf --prompt="worktree> " --height=40% --reverse \
			  --preview='git -C {1} log --oneline -10') || return 0
	local path
	path=$(echo "$selection" | awk '{print $1}')
	cd "$path"
}

# Remove a worktree via fzf, with confirmation.
# Skips the main worktree. Prompts twice if there are uncommitted changes.
# Usage: wt-rm
wt-rm() {
	# Exclude the main worktree (the one with .git directory, not a .git file)
	local selection
	selection=$(git worktree list 2>/dev/null \
		| awk 'NR>1' \
		| fzf --prompt="remove worktree> " --height=40% --reverse \
			  --preview='git -C {1} status --short') || return 0

	local path
	path=$(echo "$selection" | awk '{print $1}')
	local branch
	branch=$(echo "$selection" | awk '{print $3}' | tr -d '[]')

	read -r -p "Remove worktree '${branch}' at ${path}? [y/N] " confirm
	[[ "$confirm" =~ ^[Yy]$ ]] || return 0

	# Check for uncommitted changes
	if ! git -C "$path" diff --quiet 2>/dev/null || ! git -C "$path" diff --cached --quiet 2>/dev/null; then
		echo "Warning: worktree has uncommitted changes."
		read -r -p "Force remove anyway? [y/N] " force_confirm
		[[ "$force_confirm" =~ ^[Yy]$ ]] || return 0
		git worktree remove --force "$path"
	else
		git worktree remove "$path"
	fi
}
