eval "$(/opt/homebrew/bin/brew shellenv zsh)"

export PATH="$HOME/.local/bin:$PATH"

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Shims on PATH here so non-interactive login shells (`zsh -lc`) get pyenv's python too
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
