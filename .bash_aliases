alias c="clear"
alias q="exit"
alias la="ls -a"
alias ll="ls -l"
alias up="cd .."

alias work="cd /Users/leroy/Documents"
alias evi="cd ~/Documents/Evichat"
alias ans="cd ~/Documents/Evichat-Ansible"
alias desk="cd ~/Documents/Evichat-Desktop"
alias ai="cd ~/Documents/Evichat-Python"
alias stg="ssh ubuntu@35.182.107.135"

alias g="git"
alias ga='git add'
alias gb='git branch'
alias gc="git checkout"
alias gd="git diff --cached --name-only"
alias gm="git merge"
alias gpull="git pull"
alias gpush="git push"
alias cmt="git commit -m"
alias rb='git rebase'
alias master='git checkout master && git pull'
alias deps='bundle-stats versions'

# Handy functions

push () 
{
	if test "$#" -ne 1; then
		branch="$(git rev-parse --abbrev-ref HEAD)"
		echo "Pushing ${branch}..."
		ssh-add -K ~/.ssh/id_rsa
        	bundle exec cap staging deploy BRANCH=$branch
		return 0
	fi

	find="$(git branch --list $1)"

	if [ -z "$find" ]; then
		echo "Cannot find branch $1".
		return 1;
	fi

	ssh-add -K ~/.ssh/id_rsa
	bundle exec cap staging deploy BRANCH=$1
}

gcb ()
{
	if test "$#" -ne 1; then
                echo "Usage: gcb <branch_name>"
                echo "  to create fresh branch <branch_name> from master."
                return 1;
        fi

	git checkout master
	git pull
	git checkout -b $1
}

# Git branch bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
  
  # Add git completion to aliases
  __git_complete g __git_main
  __git_complete gc _git_checkout
  __git_complete gm _git_merge
fi


