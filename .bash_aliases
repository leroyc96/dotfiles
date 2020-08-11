alias c='clear'
alias q='exit'
alias la='ls -a'
alias ll='ls -l'
alias grep='grep --color=auto'
alias rmi='rm -i'

alias dev='cd ~/dev'
alias ccd='cd ~/dev/credit_card'
alias rhc='cd ~/dev/ReleafHaven/client'
alias ui='cd ~/dev/credit_card/product/dashboard'


alias remsh='pre-remsh -p'
alias remsh-stg='~/dev/credit_card/script/brex-remsh -k staging -c 3ba13b6caff343daa1329f076c006d97 -p'
alias fwd='while true; do kubectl port-forward svc/pgbouncer-core 5555:5432 -n storage; done'
alias fwd-erp='while true; do kubectl port-forward svc/pgbouncer-erp  5556:5432 -n storage; done'
alias fwd-stg='while true; do kubectl port-forward --context staging --namespace staging svc/core-pgbouncer 6666:5432; done'
alias fwd-stg-erp='while true; do kubectl port-forward --context staging --namespace staging svc/erp-pgbouncer 7777:5432; done'
alias resevents='~/dev/credit_card/script/dev-reset-events -n leroy'
alias tp='cd ~/dev/credit_card && script/brex-telepres -d'
alias tp-stg='cd ~/dev/credit_card && script/brex-telepres -l bash -n staging -k staging -d'

alias flint='yarn lint:fix'
alias typegen='yarn types:generate'
alias sb='yarn storybook'
alias dbash='cd ~/dev/credit_card && script/exec bash'
alias k='pre-kubectl'
alias km='cd ~/dev/credit_card && keymaster && cg-client'
alias grd='git reset product/dashboard/env/development product/dashboard/package.json mix.lock'
alias 2fa='pre-get-2fa'

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gd='git diff --cached --name-only'
alias gm='git merge'
alias gl='git checkout -'
alias gr='git reset'
alias gs='git status'
alias pull='git pull'
alias push='git push'
alias cmt='git commit -m'
alias rb='git rebase'
alias stash='git stash'
alias gcm='git checkout main  && git pull'
alias deps='bundle-stats versions'

# Handy functions
gbc ()
{
	if test "$#" -ne 1; then
                echo "Usage: gcb <branch_name>"
                echo "  to create fresh branch <branch_name> from master."
                return 1;
        fi

	git checkout main 
	git pull
	git checkout -b $1
}

up() { local x='';for i in $(seq ${1:-1});do x="$x../"; done;cd $x; }

rme()
{
	pod=$(kubectl get pods -o name | cut -d / -f 2 | grep "^$1" | head -n 1)
	echo "Execing into $pod"
	kubectl exec $pod -it -- bash -c 'if ! [ -x "$(command -v vim)" ]; then apt-get update && apt-get install vim -y; fi; bash'
}

rme-stg()
{
        pod=$(kubectl get pods --context staging --namespace staging -o name | cut -d / -f 2 | grep "^$1" | head -n 1)
        echo "Execing into $pod"
        kubectl exec $pod --context staging --namespace staging -it -- bash -c 'if ! [ -x "$(command -v vim)" ]; then apt-get update && apt-get install vim -y; fi; bash'
}

squash()
{
	if test "$#" -ne 1; then
		echo "Please indicate number of commits to squash."
		return 1
	fi

	git rebase -i HEAD~$1
}

# Git branch bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
  
  # Add git completion to aliases
  __git_complete g __git_main
  __git_complete gc _git_checkout
  __git_complete gm _git_merge
fi
