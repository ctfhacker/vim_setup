#!/bin/bash

cp -r .vim* ~
cp .bash_profile ~
cp .bashrc ~
gnome-terminal-colors-solarized/set_dark.sh
cp dircolors.ansi-dark ~/.dircolors
cp .gitconfig ~

# Install Cross-compile MIPS/ARM
sudo apt-get install qemu qemu-user qemu-user-static
sudo apt-get install gdb-multiarch
sudo apt-get install 'binfmt*'
sudo apt-get install libc6-armhf-armel-cross
sudo apt-get install debian-keyring
sudo apt-get install debian-archive-keyring
sudo apt-get install emdebian-archive-keyring
sudo tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF
sudo apt-get update
sudo apt-get install libc6-mipsel-cross # For MIPS-EL
sudo apt-get install libc6-arm-cross    # For ARM
sudo apt-get install gcc-4.4-mipsel-linux-gnu # For MIPS-EL
sudo apt-get install gcc-arm-linux-gnueabihf  # For ARM
sudo mkdir /etc/qemu-binfmt
sudo ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel # MIPSEL
sudo ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm # ARM
sudo rm /etc/apt/sources.list.d/emdebian.list
sudo apt-get update

# Install binjitsu
apt-get update
apt-get install python2.7 python-pip python3-pip python-dev git
pip install --upgrade git+https://github.com/binjitsu/binjitsu.git

# Install pwndbg
mkdir ~/workspace
cd ~/workspace
git clone https://github.com/zachriggle/pwndbg
echo "source $PWD/pwndbg/gdbinit.py" >> ~/.gdbinit

# Install Capstone 4.0 for pwndbg
cd ~/workspace
git clone https://github.com/aquynh/capstone
cd capstone
git checkout -t origin/next
sudo ./make.sh install
cd bindings/python
sudo python3 setup.py install

# Install pycparser for pwndbg
pip3 install pycparser

# Install tmux.conf
cp tmux.conf ~/.tmux.conf

# Install terminator and config
sudo apt-get install terminator
mkdir -p ~/.config/terminator
cp terminator-config ~/.config/terminator/config
