# Enable for debugging purposes, it logs every command ran in the terminal
# set -x

unalias -a
set -o vi

# The theme we'll be using
. $HOME/.bash_theme

export PATH=$PATH:$HOME/scripts

bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string "\1\e[1;32m\2+\1\e[0m\2 "'
bind 'set vi-cmd-mode-string "\1\e[1;32m\2:\1\e[0m\2 "'

#hotkeys
bind '"\e[A": history-search-backward'
bind '"\eOA": history-previous-history'

# Set NVM_DIR and source the nvm and bash_completion scripts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Source the cargo environment
. "$HOME/.cargo/env"

# Set up XDG_CONFIG_HOME and VIM
export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim --listen /tmp/nvim-server.pipe"

# Source personal environment and files
PERSONAL=$XDG_CONFIG_HOME/personal
. $PERSONAL/env
for i in $(find -L $PERSONAL -type f); do
	. $i
done

# Set up GOPATH and GIT_EDITOR
export GOPATH=$HOME/go
export GIT_EDITOR=$VIM

# Set up PATH
export PATH=$HOME/.local/.npm-global/bin:$HOME/.local/bin:$HOME/.local/n/bin/:$HOME/.local/go/bin:$HOME/go/bin:$PATH
export PATH=$HOME/scripts:$PATH

# Bind key to tmux-sessionizer
# bindkey -s ^f "tmux-sessionizer\n"

# Set VISUAL and EDITOR
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
	export VISUAL="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
else
	export VISUAL="nvim"
fi
export EDITOR="$VISUAL"

# Set up RUST environment
export PATH=$HOME/.cargo/bin:$PATH
# export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"
# . $HOME/.cargo/env
# if [ ! -f "$HOME/.config/rustlang/autocomplete/rustup" ]; then
# 	mkdir -p ~/.config/rustlang/autocomplete
# 	rustup completions bash rustup >>~/.config/rustlang/autocomplete/rustup
# fi
# . "$HOME/.config/rustlang/autocomplete/rustup"
# if ! command -v rust-analyzer &>/dev/null; then
# 	brew install rust-analyzer
# fi
# if ! cargo audit --version &>/dev/null; then
# 	cargo install cargo-audit --features=fix
# fi
# if ! cargo nextest --version &>/dev/null; then
# 	cargo install cargo-nextest
# fi
# if ! cargo fmt --version &>/dev/null; then
# 	rustup component add rustfmt
# fi
# if ! cargo clippy --version &>/dev/null; then
# 	rustup component add clippy
# fi
# if ! ls ~/.cargo/bin | grep 'cargo-upgrade' &>/dev/null; then
# 	cargo install cargo-edit
# fi

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

###

if [ -n "$SSH_AUTH_SOCK" ]; then
	ssh-add -q ~/.ssh/id_ed25519.github
fi

export PIPENV_VENV_IN_PROJECT=1

# export TERM=xterm-256color

bind 'set bell-style none'
export PATH=$HOME/android_sdk/cmdline-tools/latest/bin/:$PATH

# complete -o default -F __start_kubectl k
