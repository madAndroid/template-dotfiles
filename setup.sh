#!/bin/sh

echo '
                          /$$                                      /$$      
                         | $$                                     | $$      
     /$$$$$$$  /$$$$$$  /$$$$$$   /$$   /$$  /$$$$$$      /$$$$$$$| $$$$$$$ 
    /$$_____/ /$$__  $$|_  $$_/  | $$  | $$ /$$__  $$    /$$_____/| $$__  $$
   |  $$$$$$ | $$$$$$$$  | $$    | $$  | $$| $$  \ $$   |  $$$$$$ | $$  \ $$
    \____  $$| $$_____/  | $$ /$$| $$  | $$| $$  | $$    \____  $$| $$  | $$
    /$$$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$/| $$$$$$$//$$ /$$$$$$$/| $$  | $$
   |_______/  \_______/   \___/   \______/ | $$____/|__/|_______/ |__/  |__/
                                           | $$                             
                                           | $$                             
                                           |__/
   
   *** This is dotfiles setup script ***

   1. Download https://github.com/shunk031/dotfiles
   2. Symlinking dot files to your home directory
   3. To run install.sh in order to install the required application
'

# To input "yes" or "no" to the user
askYesOrNo() {
    while true ; do
	read -p "$1 (y/n)? " answer
	case $answer in
	    [yY] | [yY]es | YES )
		return 0;;
	    [nN] | [nN]o | NO )
		return 1;;
	    * ) echo "Please answer yes or no.";;
	esac
    done
}



# Create some symbolic links to home directory
ln -sfn ~/dotfiles/bashrc ~/.bashrc
echo "Created symbolic link of bashrc to home directory"

ln -sfn ~/dotfiles/profile ~/.profile
echo "Created symbolic link of profile to home directory"

ln -sfn ~/dotfiles/Xresources ~/.Xresources
echo "Created symbolic link of Xresources to home directory"

ln -sfn ~/dotfiles/xinitrc ~/.xinitrc
echo "Created symbolic link of xinitrc to home directory"

ln -sfn ~/dotfiles/zshrc ~/.zshrc
echo "Created symbolic link of zshrc to home directory"

ln -sfn ~/dotfiles/zlogin ~/.zlogin
echo "Created symbolic link of zlogin to home directory"

ln -sfn ~/dotfiles/zlogout ~/.zlogout
echo "Created symbolic link of zlogout to home directory"

ln -sfn ~/dotfiles/zpreztorc ~/.zpreztorc
echo "Created symbolic link of zpreztorc to home directory"

ln -sfn ~/dotfiles/zprofile ~/.zprofile
echo "Created symbolic link of zprofile to home directory"

ln -sfn ~/dotfiles/zshenv ~/.zshenv
echo "Created symbolic link of zshenv to home directory"

ln -sfn ~/dotfiles/Xmodmap ~/.Xmodmap
echo "Created symbolic link of Xmodmap to home directory"



# Setup Prezto
askYesOrNo "
Are you sure you want to setup Prezto?"

if [ $? -eq 0 ]; then
    
    # run zsh and clone Prezto repository
    zsh
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    setopt EXTENDED_GLOB

    # Create some symblic link to ~/.prezto
    ln -sfn ~/dotfiles/prezto.d/prompt_sorin_setup ~/.zprezto/modules/prompt/functions/prompt_sorin_setup
    echo "Created symbolic link of prompt_sorin_setup to ~/.zprezto"
else
    echo "Setting up Prezto has been canceled."
fi



# called install.sh
askYesOrNo "
Are you sure you want to run install.sh?"
if [ $? -eq 0 ]; then
    sh install.sh
else
    echo "Execution of install.sh has been canceled."
fi
