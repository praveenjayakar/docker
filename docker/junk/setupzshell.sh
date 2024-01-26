#!/bin/bash

apt update -y

apt install zsh -y

apt install git curl -y
apt install fonts-font-awesome -y

sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc


git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc


source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' ~/.zshrc

source ~/.zshrc 


