# Enable for debugging purposes, it logs every command ran in the terminal
# set -x
unalias -a
set -o vi

echo "Welcome to $(hostname)!"

# Set up PATH
export PATH="$HOME/.amplify/bin:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.local/.npm-global/bin:$HOME/.local/bin:$HOME/.local/n/bin/:$HOME/.local/go/bin:$HOME/go/bin:$HOME/bin:$HOME/bin:$HOME/scripts:$PATH
export PATH=$PATH:$HOME/scripts
export PATH="/usr/local/bin:$PATH"
export GOPATH="$HOME/go"
PATH="$GOPATH/bin:$PATH"
. "$HOME/.cargo/env"

bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string "\1\e[1;32m\2+\1\e[0m\2 "'
bind 'set vi-cmd-mode-string "\1\e[1;32m\2:\1\e[0m\2 "'

# Set NVM_DIR and source the nvm and bash_completion scripts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Set up XDG_CONFIG_HOME and VIM
export XDG_CONFIG_HOME=$HOME/.config

# Source personal environment and files
PERSONAL=$XDG_CONFIG_HOME/personal/bash
for i in $(find -L $PERSONAL -type f); do
	. $i
done

COMMON=$XDG_CONFIG_HOME/common
for i in $(find -L $COMMON -type f); do
	. $i
done

# Set VISUAL and EDITOR
export EDITOR="nvim"
export GIT_EDITOR=$EDITOR

export menu="bemenu"

export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/

bind 'set bell-style none'

# Temp fix for atuin https://github.com/atuinsh/atuin/issues/1012
eval "$(atuin init bash --disable-up-arrow)"

_atuin_fix_echo() {
	stty echo
	stty sane
}

if [[ -n "${BLE_VERSION-}" ]]; then
	blehook PRECMD-+=_atuin_fix_echo
else
	precmd_functions+=(_atuin_fix_echo)
fi
# end atuin

if [[ -f ~/.ssh/id_ed25519.github ]]; then
	eval $(ssh-agent -s)
	ssh-add ~/.ssh/id_ed25519.github
fi

source ~/.config/broot/launcher/bash/br
source ~/.config/wezterm/wezterm.sh
eval "$(zoxide init bash)"
eval "$(starship init bash)"

[[ -e ~/.config/personal/bash/alias_personal ]] && \. ~/.config/personal/bash/alias_personal

for f in ~/bash/completions*; do
	. $f
done

# Have to install bash-preexec as well
# causing issues with starship https://unix.stackexchange.com/questions/762231/bash-customization-only-take-place-after-interacting-with-the-terminal-for-the-f
# [[ -e ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
