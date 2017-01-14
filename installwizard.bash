#!/bin/bash

# TO DO - Add --help for each installer to display the list of
# packages that will be installed and their description.


# Allow for relative paths
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$PARENT_PATH"


install_vim()
{
curlcheck=$(curl --version | head -n 1 | tr " " "\n" | head -n 1)
sedcheck=$(sed --version | head -n 1 | tr " " "\n" | head -n 1)

if [ -z $curlcheck ]; then 
    sudo apt-get install -y curl
fi

if [ -z $sedcheck]; then 
    sudo apt-get install -y sed
fi

sudo apt-get install -y vim

echo "[$FUNCNAME] Configuring vim..."
cp $PARENT_PATH/dotfiles/.vimrc /home/$USER/
printf "\n\n" >> /home/$USER/.bashrc
cat $PARENT_PATH/includes/bashrc_vimrc.update >> /home/$USER/.bashrc

echo "[$FUNCNAME] Setting up vim plugins..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

sed -i '16s/" //' /home/$USER/.vimrc
sed -i '17s/" //' /home/$USER/.vimrc
}


install_git()
{
vimcheck=$(vim --version | head -n 1 | tr " " "\n" | head -n 1)

sudo apt-get install -y git

echo "[$FUNCNAME] Configuring git..."
git config --global user.name Radoslaw Kieltyka
git config --global user.email rkieltyka@dataplicity.com
git config credential.helper 'cache --timeout=9000'

git remote add wf-specialproj-pub https://github.com/wildfoundry/specialprojects-public
git remote add wf-specialproj-priv https://github.com/wildfoundry/specialprojects
git remote add wf-wfos https://github.com/wildfoundry/wf-os
git remote add rados https://github.com/Radoslaw-K/rados

if [ $vimcheck == "VIM" ]; then 
    git config --global core.editor vim
fi
}


install_sqlite3()
{
sudo apt-get install -y sqlite3

echo "[$FUNCNAME] Configuring sqlite3..."
cp $PARENT_PATH/dotfiles/.sqliterc /home/$USER/
}


install_build_tools()
{
sudo apt-get install -y bison libtool build-essential autotools-dev automake zlib1g-dev libglib2.0-dev libpixman-1-dev flex
}


install_python_tools()
{
sudo apt-get install -y python-pip
sudo pip install flake8 coverage ipython pexpect
}


install_extras()
{
sudo apt-get install -y cmatrix redshift
}


install_general()
{
sudo apt-get -y install tree httpie terminator silversearcher-ag strace screen inotify-tools
}


install_prompt_strings()
{
teecheck=$(tee --version | head -n 1 | tr " " "\n" | head -n 1)
gitcheck=$(git --version | head -n 1 | tr " " "\n" | head -n 1)

if [ -z $teecheck ]; then 
    sudo apt-get install -y tee
fi

if [ $gitcheck == "git" ]; then
    user_ps_command="export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w $(__git_ps1 " <%s>") \$\[\033[00m\] '"
else
    echo "[$FUNCNAME] Git not found on the system, will not be part of the string..."
    user_ps_command="export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '"
fi

root_ps_command="export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[1;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w #\[\033[00m\] '"

echo "[$FUNCNAME] Installing prompt string for user: $USER..."
echo $user_ps_command >> /home/$USER/.bashrc

echo "[$FUNCNAME] Installing prompt string for user: root..."
echo $root_ps_command | sudo tee --append /root/.bashrc > /dev/null
}


install_bashrc_extras()
{
echo "[$FUNCNAME] Installing custom bash commands..."
printf "\n\n" >> /home/$USER/.bashrc
cat $PARENT_PATH/includes/bashrc_commands.extra >> /home/$USER/.bashrc
}


#install_all()
#{
# TODO - Generate this list automatically
#install_general
#install_extras
#install_python_tools
#install_build_tools
#install_sqlite3
#install_git
#install_vim
#install_prompt_strings
#install_bashrc_extras
#}


# --------------------------------------------- MAIN --------------------------------------------- #
func_list_raw=$(typeset -F | grep install_)
str_old="declare -f "
str_new=""
func_list="${func_list_raw//$str_old/$str_new}"


if [ $USER == "root" ]; then
echo "
--------------------------------------------------------------------
[ERROR] Not allowed to run the script as: $USER. 
Please log in as a different user.
"
exit 0
fi


if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
echo "
--------------------------------------------------------------------
Script ${BASH_SOURCE[0]} has been loaded into bash.
"
echo "
--------------------------------------------------------------------
Available installation commands:

$(printf "$func_list")
"

else

echo "
--------------------------------------------------------------------
Load the script using command below:
source ${0}
"
fi
