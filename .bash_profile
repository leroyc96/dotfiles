if [ -f /usr/local/etc/bash_completion ]; then
	. /usr/local/etc/bash_completion
	__git_complete g _git_main
	__git_complete gb _git_branch
	__git_complete gc _git_checkout
fi

[ -f ~/.git-completion.bash ] && . ~/.git-completion.bash

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

[ -f ~/.bash_prompt ] && . ~/.bash_prompt

[ -f ~/.bashrc ] && . ~/.bashrc

