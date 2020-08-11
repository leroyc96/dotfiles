command -v nodenv &> /dev/null && eval "$(nodenv init -)"
export BREX_DEV_NAMESPACE=leroy
export KUBECONFIG=~/.kube/config

if which kubectl > /dev/null 2>&1; then
    . /usr/local/etc/profile.d/bash_completion.sh
    source <(kubectl completion bash)
fi

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export PATH="$HOME/dev/credit_card/script/preview-environments:$PATH"

. $(brew --prefix asdf)/asdf.sh

. /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash
