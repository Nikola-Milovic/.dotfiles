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
# bind '"\e[A": history-search-backward'
# bind '"\eOA": history-previous-history'

# Set NVM_DIR and source the nvm and bash_completion scripts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Set up XDG_CONFIG_HOME and VIM
export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim --listen /tmp/nvim-server.pipe"

# Source personal environment and files
PERSONAL=$XDG_CONFIG_HOME/personal/bash
for i in $(find -L $PERSONAL -type f); do
	. $i
done

COMMON=$XDG_CONFIG_HOME/common
for i in $(find -L $COMMON -type f); do
	. $i
done

# Set up GOPATH and GIT_EDITOR
export GOPATH=$HOME/go
export GIT_EDITOR=$VIM

# Set up PATH
export PATH=$HOME/.local/.npm-global/bin:$HOME/.local/bin:$HOME/.local/n/bin/:$HOME/.local/go/bin:$HOME/go/bin:$HOME/bin:$HOME/bin:$HOME/scripts:$PATH

# Set VISUAL and EDITOR
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
	export VISUAL="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
else
	export VISUAL="nvim"
fi
export EDITOR="$VISUAL"

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

bind 'set bell-style none'
# complete -o default -F __start_kubectl k

eval "$(atuin init bash --disable-up-arrow)"

# Add the code below

_atuin_fix_echo() {
    stty echo
    stty sane
}

if [[ -n "${BLE_VERSION-}" ]]; then
    blehook PRECMD-+=_atuin_fix_echo
else
    precmd_functions+=(_atuin_fix_echo)
fi
