alias c='clear'
alias q='exit'
alias la='ls -a'
alias ll='ls -l'
alias up='cd ..'
alias grep='grep --color=auto'

alias work='cd /Users/leroy/Documents'

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gd='git diff --cached --name-only'
alias gm='git merge'
alias gs='git status'
alias pull='git pull'
alias push='git push'
alias cmt='git commit -m'
alias rb='git rebase'
alias stash='git stash'
alias master='git checkout master && git pull'
alias deps='bundle-stats versions'

# Handy functions
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
