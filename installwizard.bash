#!/bin/bash

# TO DO - Add --help for each installer to display the list of
# packages that will be installed and their description.


# Allow for relative paths
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$PARENT_PATH"


install_vim()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


curlcheck=$(curl --version 2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)
sedcheck=$(sed --version  2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)

if [ -z $curlcheck ]; then 
    sudo apt-get install -y curl
fi

if [ -z $sedcheck ]; then 
    sudo apt-get install -y sed
fi

sudo apt-get install -y vim

echo "[$FUNCNAME] Configuring vim..."
cp $PARENT_PATH/dotfiles/.vimrc /home/$USER/
printf "\n" >> /home/$USER/.bashrc
cat $PARENT_PATH/includes/bashrc_vimrc.update >> /home/$USER/.bashrc

echo "[$FUNCNAME] Setting up vim plugins..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qall

sed -i '16s/" //' /home/$USER/.vimrc
sed -i '17s/" //' /home/$USER/.vimrc
}


install_git()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


vimcheck=$(vim --version  2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)
curlcheck=$(curl --version  2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)

if [ -z $curlcheck ]; then 
    sudo apt-get install -y curl
fi

sudo apt-get install -y git

echo "[$FUNCNAME] Configuring git..."
git config --global user.name Radoslaw Kieltyka
git config --global user.email rkieltyka@dataplicity.com
git config credential.helper 'cache --timeout=9000'

git remote add wf-specialproj-pub https://github.com/wildfoundry/specialprojects-public
git remote add wf-specialproj-priv https://github.com/wildfoundry/specialprojects
git remote add wf-wfos https://github.com/wildfoundry/wf-os
git remote add rados https://github.com/Radoslaw-K/rados

curl -o ~/.git-prompt.sh \
        https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

printf "\n" >> /home/$USER/.bashrc
printf "source ~/.git-prompt.sh\n" >> /home/$USER/.bashrc

if [ $vimcheck == "VIM" ]; then 
    git config --global core.editor vim
fi
}


install_sqlite3()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


sudo apt-get install -y sqlite3

echo "[$FUNCNAME] Configuring sqlite3..."
cp $PARENT_PATH/dotfiles/.sqliterc /home/$USER/
}


install_build_tools()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


sudo apt-get install -y bison libtool build-essential autotools-dev automake zlib1g-dev libglib2.0-dev libpixman-1-dev flex gawk cmake gperf chrpath texinfo git-core diffstat unzip gcc-multilib socat libsdl1.2-dev xterm
}


install_python_tools()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


sudo apt-get install -y python-dev
sudo apt-get install -y python3-dev
sudo apt-get install -y python-pip
sudo pip install flake8 coverage ipython pexpect
}


install_extras()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


sudo apt-get install -y cmatrix redshift
}


install_general()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


sudo apt-get -y install tree httpie terminator silversearcher-ag strace screen inotify-tools
}


install_prompt_strings()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


USER_GIT_PS_LOCATION=8
USER_PS_LOCATION=11
ROOT_PS_LOCATION=14

teecheck=$(tee --version  2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)
gitcheck=$(git --version  2>/dev/null | head -n 1 | tr " " "\n" | head -n 1)

if [ -z $teecheck ]; then 
    sudo apt-get install -y tee
fi

echo "[$FUNCNAME] Installing prompt string for user: $USER..."
printf "\n" >> /home/$USER/.bashrc

if [ -z $gitcheck ]; then
    echo "[$FUNCNAME] Git not found on the system, will not be part of the string..."
    cat $PARENT_PATH/includes/bashrc_gitps.update | head -n $USER_PS_LOCATION | tail -n 1 >> /home/$USER/.bashrc
else
    cat $PARENT_PATH/includes/bashrc_gitps.update | head -n $USER_GIT_PS_LOCATION | tail -n 1 >> /home/$USER/.bashrc
fi

echo "[$FUNCNAME] Installing prompt string for user: root..."
printf "\n" >> /home/$USER/.bashrc
cat $PARENT_PATH/includes/bashrc_gitps.update | head -n $ROOT_PS_LOCATION | tail -n 1 | sudo tee --append /root/.bashrc > /dev/null
}


install_bashrc_extras()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


echo "[$FUNCNAME] Installing custom bash commands..."
printf "\n" >> /home/$USER/.bashrc
cat $PARENT_PATH/includes/bashrc_commands.extra >> /home/$USER/.bashrc
}


install_all()
{

if [[ $# -eq 1 ]]; then
case $1 in
    -h | --help)
        echo this is bla
	exit 0
        ;;
    *)
        echo incorrect arg
        exit 1
        ;;
esac
fi


# $(script_list_functions)
# bash -c "source ${0} &&  $(script_list_functions)"
echo "This option has not been implemented yet. $2"
}


script_help()
{
echo "------------------------------------------------------------------------------------
Usage:
    ${0} COMMAND [OPTION] 
    ** See below for available options **
OR
    source ${0}
    ** Available commands will be printed after the script is sourced **


Available COMMAND(s):
    all              [-h | --help]
    bashrc_extras    [-h | --help]
    build_tools      [-h | --help]
    extras           [-h | --help]
    general          [-h | --help]
    git              [-h | --help]
    prompt_strings   [-h | --help]
    python_tools     [-h | --help]
    sqlite3          [-h | --help]
    vim              [-h | --help]
    help             [-h | --help]
"
}


script_list_functions()
{
func_list_raw=$(typeset -F | grep install_)
str_old="declare -f "
str_new=""
func_list="${func_list_raw//$str_old/$str_new}"
printf "$func_list\n"
}



# ---------------------------------------- MAIN ---------------------------------------- #


if [ $USER == "root" ]; then
echo "------------------------------------------------------------------------------------
[ERROR]
    Not allowed to run the script as: $USER.
    Please log in as a different user."
exit 1
fi 


if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then

echo "------------------------------------------------------------------------------------
Script ${BASH_SOURCE[0]} has been loaded into bash.

Available installation commands:

$(script_list_functions)"

else

case $1 in
    all)
        install_all $2
        ;;
    bashrc_extras)
        install_bashrc_extras $2
        ;;
    build_tools)
        install_build_tools $2
        ;;
    extras)
        install_extras $2
        ;;
    general)
        install_general $2
        ;;
    git)
        install_git $2
        ;;
    prompt_strings)
        install_prompt_strings $2
        ;;
    python_tools)
        install_python_tools $2
        ;;
    sqlite3)
        install_sqlite3 $2
        ;;
    vim)
        install_vim $2
        ;;
    help)
        script_help
        ;;
    *)
        script_help
        exit 1
esac

fi
