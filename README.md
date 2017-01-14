![alt text](https://dotfiles.github.io/images/dotfiles-logo.png)

### Setup

Some versions of ubuntu don't have git installed by default, install using:

`sudo apt-get install -y git`

Load the installers using this command. Further instructions will be given in terminal emulator window:

`git clone -b ubuntu https://github.com/Radoslaw-K/dotfiles && cd dotfiles/ && source installwizard.bash`

### Possible problems

When running on LXD containers, SSL certificate issues may arise when cloning git branch, this is solved by running:

`git config --global http.sslVerify false`
