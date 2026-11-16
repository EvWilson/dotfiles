# My wonderful little preferences, aliases, functions, etc, to make my shell feel like home
# Works in both bash and zsh. Add this line to the end of .bashrc or .zshrc to load it in:
# [ -s "${HOME}/.dotfiles/rc_ext.sh" ] && \. "${HOME}/.dotfiles/rc_ext.sh"

# Colors to see dirs and bins
LS_COLORS="di=34:ex=33"
export LS_COLORS

# Set custom prompt
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
# Shorten the cwd to the first letter of each dir except the last, e.g. ~/a/b/project
short_pwd() {
	local p="${PWD#${HOME}}" out="" q
	[ "${PWD}" != "${p}" ] && out="~"
	p="${p#/}"
	while [ "${p#*/}" != "${p}" ]; do
		q="${p%%/*}"
		out="${out}/${q:0:1}"
		p="${p#*/}"
	done
	[ -n "${p}" ] && out="${out}/${p}"
	printf '%s' "${out}"
}
if [ -n "${ZSH_VERSION}" ]; then
	setopt PROMPT_SUBST
	PROMPT='%B%F{cyan}$(short_pwd)$(parse_git_branch)%f%b '
else
	HOST_COLOR="01;35m"
	PATH_COLOR="01;36m"
	PS1='\[\033[$PATH_COLOR\]$(short_pwd)$(parse_git_branch)\[\033[00m\] '
fi

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
	# Remove leading asterisk and spaces, as in case of currently active branch
	local BRANCH=$(git branch | fzf | sed 's/^[* ]*//')
	git checkout "$BRANCH"
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
	# Not named "path", since zsh ties $path to $PATH
	local wt_path
	wt_path=$(echo "$selection" | awk '{print $1}')
	cd "$wt_path"
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

	# Not named "path", since zsh ties $path to $PATH
	local wt_path
	wt_path=$(echo "$selection" | awk '{print $1}')
	local branch
	branch=$(echo "$selection" | awk '{print $3}' | tr -d '[]')

	# printf + read rather than `read -p`, which means something else in zsh
	local confirm force_confirm
	printf "Remove worktree '%s' at %s? [y/N] " "$branch" "$wt_path"
	read -r confirm
	[[ "$confirm" =~ ^[Yy]$ ]] || return 0

	# Check for uncommitted changes
	if ! git -C "$wt_path" diff --quiet 2>/dev/null || ! git -C "$wt_path" diff --cached --quiet 2>/dev/null; then
		echo "Warning: worktree has uncommitted changes."
		printf "Force remove anyway? [y/N] "
		read -r force_confirm
		[[ "$force_confirm" =~ ^[Yy]$ ]] || return 0
		git worktree remove --force "$wt_path"
	else
		git worktree remove "$wt_path"
	fi
}
