if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# colors
PS1='\w\[\033[0;32m\]$( git branch 2> /dev/null | cut -f2 -d\* -s | sed "s/^ / (/" | sed "s/$/)/" )\[\033[0m\] \$ '

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Tell ls to be colourful
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
