![alt text](https://dotfiles.github.io/images/dotfiles-logo.png)

### Setup

Some versions of ubuntu don't have git installed by defualt, install using:
`sudo apt-get install -y git`

Load the installers using this command:
`git clone -b ubuntu https://github.com/Radoslaw-K/dotfiles && cd dotfiles/ && source installwizard.bash`

When running on LXD containers, SSL certificate issues may arise when cloning git branch, this is solved by running (otherwise skip this step):
`git config --global http.sslVerify false`
