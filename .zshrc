# zshrc

# source ~/dotfiles/zsh/functions.zsh
source ${HOME}dotfiles/bin.zsh/paths.zsh
source ${HOME}/dotfiles/bin.zsh/alias.zsh
source ${HOME}/dotfiles/bin.zsh/pyenv.zsh
source ${HOME}/dotfiles/bin.zsh/goenv.zsh
source ${HOME}/dotfiles/bin.zsh/rbenv.zsh

# export TERM color as 256 colors
export TERM=xterm-256color


# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


# load password as environment variable
if [ -e $HOME/dotfiles/bin.zsh/my_passwd.zsh ]; then
    source $HOME/dotfiles/bin.zsh/my_passwd.zsh
fi


# auto-start tmux
[[ -z "$TMUX" && ! -z "$PS1" ]] && tmux



# Run one instance of devilspie to manage window sizes (Linux only)
if [[ "$OSTYPE" =~ "linux-gnu" ]]; then
    if [ ! `pidof devilspie` ]; then
        (devilspie &)
    fi
fi
