#!/bin/bash

# TO DO - Add --help for each installer to display the list of
# packages that will be installed and their description.


# Allow for relative paths
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$PARENT_PATH"


check_is_installed()
{
FUNCTION=$1
FILE=$2
DESTINATION=$3

beg=$(grep "### $FILE {" $DESTINATION) 
end=$(grep "### } $FILE" $DESTINATION) 

if [[ ${beg} && ${end} ]]; then
    echo "[$FUNCTION] Already installed..."
    return 1
elif [[ (${beg} && ! ${end}) || (! ${beg} && ${end}) ]]; then
    echo "[$FUNCTION] Previously installed but now in broken state..."
    echo ""
    echo "[ERROR]"
    echo "    One of the positional markers below is missing inside \"$DESTINATION\":"
    echo "    \"### $FILE {\""
    echo "    \"### } $FILE\""
    return 1
else
    return 0
    fi
}


check_uninstall()
{
FUNCTION=$1
FILE=$2
DESTINATION=$3

beg=$(grep "### $FILE {" $DESTINATION) 
end=$(grep "### } $FILE" $DESTINATION) 

if [[ ${beg} && ${end} ]]; then
    return 0
elif [[ (${beg} && ! ${end}) || (! ${beg} && ${end}) ]]; then
    echo "[$FUNCTION] Previously installed but now in broken state..."
    echo ""
    echo "[ERROR]"
    echo "    One of the positional markers below is missing inside \"$DESTINATION\":"
    echo "    \"### $FILE {\""
    echo "    \"### } $FILE\""
    return 1
else
    echo "[$FUNCTION] Not installed previously..."
    return 1
    fi
}


install_bashrc_extras()
{

FILE="bashrc_commands.extra"
DESTINATION="/home/$USER/.bashrc"

if [[ $# -ne 1 ]]; then
    echo [$FUNCNAME] requires 1 argument.
    return 1
    fi

case $1 in
    -i | --install)
        check_is_installed $FUNCNAME $FILE $DESTINATION
        if [[ $? -eq 1 ]]; then
            return 1
            fi

        echo "[$FUNCNAME] Installing custom bash commands..."
        printf "\n" >> $DESTINATION
        sed s/THIS_FILENAME/$FILE/g  $PARENT_PATH/includes/$FILE >> $DESTINATION
        ;;

    -u | --uninstall)
        check_uninstall $FUNCNAME $FILE $DESTINATION
        if [[ $? -eq 1 ]]; then
            return 1
            fi

        echo "[$FUNCNAME] Uninstalling custom bash commands..."
        sed -i '/### '"$FILE"' {/,/### } '"$FILE"'/d' $DESTINATION
        if [[ -z $(tail -n 1 $DESTINATION) ]]; then
            sed -i '$ d' $DESTINATION
            fi
        ;;

    -h | --help)
        echo "This function installs custom commands found in $FILE to ~/.bashrc"
        echo "Usage: $FUNCNAME [OPTION]"
        echo ""
        echo "OPTION(s):"
        echo "    -i | --install"
        echo "    -u | --uninstall"
        echo "    -h | --help"
        return 0
        ;;

    *)
        echo "[$FUNCNAME] Incorrect argument"
        echo "Use -h or --help for usage information"
        return 1
        ;;

    esac
}


install_build_tools()
{

PACKAGES="\
    automake \
    autotools-dev \
    bison \
    build-essential \
    chrpath \
    cmake \
    diffstat \
    flex \
    gawk \
    gcc-multilib \
    git-core \
    gperf \
    libglib2.0-dev \
    libpixman-1-dev \
    libsdl1.2-dev \
    libtool \
    socat \
    unzip \
    texinfo \
    xterm \
    zlib1g-dev"

if [[ $# -ne 1 ]]; then
    echo [$FUNCNAME] requires 1 argument.
    return 1
    fi

case $1 in
    -i | --install)
        sudo apt-get install -y ${PACKAGES}
        ;;

    -u | --uninstall)
        sudo apt autoremove -y ${PACKAGES}
        ;;

    -h | --help)
        echo "This function installs libraries and tools needed for building"
        echo "applications from source"
        echo "Usage: $FUNCNAME [OPTION]"
        echo ""
        echo "OPTION(s):"
        echo "    -i | --install"
        echo "    -u | --uninstall"
        echo "    -h | --help"
        return 0
        ;;

    *)
        echo "[$FUNCNAME] Incorrect argument"
        echo "Use -h or --help for usage information"
        return 1
        ;;
esac


}
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
    ${0} COMMAND COMMAND_OPTION
    ** See below for available COMMAND(s) **
OR
    source ${0}
    ** Available commands will be printed after the script is sourced **


Available COMMAND(s):
    all
    bashrc_extras
    build_tools
    extras
    general
    git
    prompt_strings
    python_tools
    sqlite3
    vim
    help

For available COMMAND_OPTION(s) please run:
    COMMAND -h
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
return 1
fi 


if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then

echo "------------------------------------------------------------------------------------
Script ${BASH_SOURCE[0]} has been loaded into bash.

Available installation commands:

$(script_list_functions)"

else

if [[ $# -ne 2 ]]; then
    echo "Incorrect amount of arguments passed to the script."
    echo ""
    script_help
    exit 1
    fi

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
