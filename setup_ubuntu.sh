#!/bin/bash

#
# Setup script for Ubuntu and Debian VMs.
# TinyURL: This script is available at:
# $ wget https://goo.gl/3e2B0
# $ bash 3e2B0
#

#
# Print commands as they're run, and fail on error.
#
set -ex

#
# Don't run as root
#
if [ $UID -eq 0 ] ; then
    cat <<EOF
Run as a regular user with sudo access
# useradd -m user -p password
# echo "user ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/user
EOF
    exit
fi

if [ ! -f /etc/sudoers.d/$USER ]; then
sudo bash -c "echo '$USER ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers.d/$USER"
fi

#
# Useful environment variables
#

case "$(uname -m)" in
    i686)   ARCH="i386" ;;
    x86_64) ARCH="amd64" ;;
esac

DISTRO=$(lsb_release -is)   # 'Ubuntu'
RELEASE=$(lsb_release -cs)  # 'trusty'

#
# Default mirrors are sloooooooow
#
# us.archive.ubuntu.com => Ubuntu DVD install
# archive.ubuntu.com    => DigitalOcean install
# ftp.us.debian.org     => Debian DVD install
#
slow="(ftp|https?)://.*/(ubuntu|debian)"
fast="\1://mirrors.mit.edu/\2"
sudo mv -n /etc/apt/sources.list{,.original}
sudo cp    /etc/apt/sources.list{.original,}
sudo sed -i -E "s $slow $fast i" /etc/apt/sources.list


#
# Get around proxy filtering by user-agent
#
sudo tee /etc/apt/apt.conf.d/10user-agent <<EOF
Acquire
{
  http::User-Agent "Mozilla/5.0 (Windows NT 5.1; rv:25.0) Gecko/20100101 Firefox/25.0"
};
EOF

#
# Enable installation of cross-build stuff from debian.
#
# We use old versions since it's the only thing that doesn't
# end up having conflicts with modern Ubuntu.
#
sudo tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF

#
# Binaries and prerequisites
#
sudo apt-get -qq update
sudo apt-get -y -qq dist-upgrade

install() {
    sudo apt-get install -qq --yes $*
}

install debian-keyring
install debian-archive-keyring
install emdebian-archive-keyring

install ack-grep
install autoconf
install binutils
install build-essential
install clang-3.5 || install clang
install cmake
install curl
install libc6:i386 || true
install libc6-dbg:i386 || true
install dissy
install dpkg-dev
install emacs
install expect{,-dev}
install fortune
install gcc-aarch64-linux-gnu || true
install gcc-arm-linux-gnueabihf || true
install --force-yes gcc-4.4-mips-linux-gnu || true
install --force-yes gcc-4.4-powerpc-linux-gnu || true
install --force-yes gcc-4.4-s390-linux-gnu || true
install --force-yes gcc-4.4-sparc-linux-gnu || true
install gdb
install gdb-multiarch || true
install git-core
install htop || true
install irssi
install libbz2-dev
install libc6-dev\*
install libexpat1-dev
install libgdbm-dev
install libgmp-dev
install liblzma-dev # binwalk
install libncurses5-dev
install libncursesw5-dev
install libpcap0.8{,-dev}
install libpng-dev
install libpq-dev
install libreadline6-dev
install libsqlite3-dev
install libssl-dev
install libtool
install libxml2
install libxml2-dev
install libxslt1-dev
install linux-headers-$(uname -r)
install llvm-3.5 || install llvm
install mercurial
install nasm
install netcat-traditional
install nmap
install ntp
install openssh-blacklist
install openssh-blacklist-extra
install openssh-server
install openvpn
install patch
install qemu-system*  || true
install rar || true
install realpath
install silversearcher-ag || true
install socat
install ssh
install subversion
install tk-dev # required for ipython %paste
install tmux
install tree
install uncrustify
install vim
install xfce4-terminal || true
install yodl
install zlib1g-dev
install zsh
install unzip

#
# Configure automatic updates
#
# Automation
install unattended-upgrades

sudo tee /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
        "\${distro_id}:\${distro_codename}-security";
        "\${distro_id}:\${distro_codename}-updates";
};

Unattended-Upgrade::Mail "root";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
sudo tee /etc/apt/apt.conf.d/10periodic << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

sudo tee /etc/sysctl.d/10-ptrace.conf <<EOF
kernel.yama.ptrace_scope = 0
EOF

sudo tee /etc/sysctl.d/10-so_reuseaddr.conf <<EOF
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
EOF
sudo sysctl --system

#
# Required for 'nc -e'
#
sudo update-alternatives --set nc /bin/nc.traditional

apt-get source libc6 # for debugging libc

# GUI install?
if dpkg -l xorg > /dev/null 2>&1; then


    # Automatically log in as the current user
    lightdm=/etc/lightdm/lightdm.conf.d
    [[ -d $lightdm ]] || sudo mkdir -p $lightdm
    sudo tee $lightdm/20-autologin.conf <<EOF
[SeatDefaults]
autologin-user=$USER
EOF

    # Set Solarized colors in Gnome-Terminal, which doesn't
    # have an actual config file but uses gconf bullshit.
    wget -nc https://github.com/Anthony25/gnome-terminal-colors-solarized/archive/master.zip
    unzip master.zip
    ~/gnome-terminal-colors-solarized-master/set_dark.sh
    rm -rf gnome-terminal-colors-solarized-master

    # Disable the login prompt when the screensaver pops
    gsettings set org.gnome.desktop.screensaver lock-delay 3600                                                               ⏎
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false


    sudo add-apt-repository ppa:ubuntu-wine/ppa -y
    sudo apt-get update -qq

    install compiz
    install compiz-plugins
    install compizconfig-settings-manager
    install dconf-tools
    install gnome-system-monitor
    # install rescuetime
    install network-manager-openvpn

    wget -nc http://ftp.ussg.iu.edu/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-linux-gtk-x86_64.tar.gz
    tar xzf eclipse*gz

    # install eclipse # Don't install eclipse, since Ubuntu's is OLD
    sudo debconf-set-selections <<EOF
ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true
EOF
    install wine1.7 winetricks
    wget -nc https://www.python.org/ftp/python/2.7.7/python-2.7.7.msi
    wine msiexec /i python-2.7.7.msi /quiet  ALLUSERS=1

    gsettings set org.gnome.desktop.wm.preferences theme 'Greybird'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Sans 10'

    wget -nc https://www.rescuetime.com/installers/rescuetime_current_$ARCH.deb
    wget -nc http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_$ARCH.deb
    wget -nc https://dl.google.com/linux/direct/google-chrome-stable_current_$ARCH.deb
fi

wget -nc http://www.capstone-engine.org/download/2.1.2/capstone-2.1.2_$ARCH.deb

sudo dpkg --install *.deb || true
sudo apt-get install -f --yes

sudo apt-get -f    --silent install
sudo apt-get --yes --silent autoremove


#
# Configure SSH for pubkey only
#
sudo service ssh restart
sudo mv -n /etc/ssh/sshd_config{,.original}
sudo sh -c "cat > /etc/ssh/sshd_config <<EOF
Protocol                        2
Port                            22
PubkeyAuthentication            yes

Ciphers                         aes256-ctr

UsePAM                          no
PermitRootLogin                 no
PasswordAuthentication          no
PermitEmptyPasswords            no
KerberosAuthentication          no
GSSAPIAuthentication            no
ChallengeResponseAuthentication no
HostbasedAuthentication         no

X11Forwarding                   yes
PermitTunnel                    no
AllowTcpForwarding              yes

UsePrivilegeSeparation          sandbox
UseDNS                          no
StrictModes                     yes
Compression                     delayed

Subsystem      sftp             /usr/lib/openssh/sftp-server

AcceptEnv LANG LC_*
AcceptEnv TZ
AcceptEnv COLORFGBG
AcceptEnv WINDOW
AcceptEnv TMUX
EOF"
sudo service ssh restart

#
# Put the IP address on the login screen
#
cat >issue <<EOF
if [[ "\$reason" == "BOUND" ]];
then
    rm /etc/issue
    lsb_release -ds       >> /etc/issue
    echo \$new_ip_address >> /etc/issue
    echo "\\n \\l"        >> /etc/issue
fi
EOF
sudo chown root.root issue
sudo mv    issue     /etc/dhcp/dhclient-enter-hooks.d

#
# Set up home directory repo
#
# This should set up pyenv and a bunch of other things
#
cd ~
[ -d .git ] && git submodule foreach 'rm -rf $(pwd)'
[ -d .git ] && rm -rf .git
git init
git remote add origin https://github.com/zachriggle/tools.git
git fetch -q --all
git checkout -f master
git reset -q --hard
git submodule update -f -q --init --recursive

#
# Force pyenv for this script
#
PYENV_ROOT="$PWD/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#
# Install a local version of Python.
#
pyenv install $(cat .python-version)


#
# Python things
#
pip_force_install() {
    pip install --upgrade --allow-all-external --allow-unverified $* $*
}
pip_install() {
    pip install --upgrade $*
}
pip_install pygments
pip_install pexpect
pip_force_install hg+http://hg.secdev.org/scapy || true # scapy is down
pip_install tldr
pip_install httpie
pip_install ipython
pip_install hub
pip_install git-up

git clone https://github.com/Gallopsled/pwntools
cd ~/pwntools
bash .travis_install.sh
bash .travis_ssh_setup.sh
cd ~

#
# Pwntools binary requirements
#
sudo add-apt-repository ppa:pwntools/binutils -y
sudo apt-get update -qy
sudo apt-get install binutils-{aarch64,alpha,arm,avr,cris,hppa,i386,ia64,m68k,msp430,powerpc{,64},sparc{,64},vax,xscale}-linux-gnu


#
# Ruby things
#
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/jamis/rbenv-gemset.git     ~/.rbenv/plugins/rbenv-gemset
PATH="$PATH:$PWD/.rbenv/shims:$PWD/.rbenv/bin"
rbenv install        2.1.5
rbenv gemset  create 2.1.5 gems
rbenv rehash

gem install bundler
gem install gist
gem install git-up

rbenv rehash

#
# Set up metasploit
#
# case "$(uname -m)" in
#     "x86_64" ) metasploit_url="http://goo.gl/G9oxTe" ;;
#     "i686" )   metasploit_url="http://goo.gl/PwzxlC" ;;
# esac
# wget  -O ./metasploit-installer "$metasploit_url"
# chmod +x ./metasploit-installer
# sudo     ./metasploit-installer --mode unattended
# rm       ./metasploit-installer
# sudo     update-rc.d metasploit disable
# sudo     service metasploit stop
cd ~
wget -nc https://github.com/rapid7/metasploit-framework/archive/release.zip
unzip release.zip
cd metasploit-framework-*
rm -f .ruby-version
gem install bundler # metasploit has its own gemset
bundle install

#
# Set up binwalk
#
cd ~
git clone git://github.com/devttys0/binwalk.git
cd binwalk
python setup.py install
sudo rm -rf binwalk

#
# Use zsh
#
sudo chsh -s $(which zsh) $(whoami)

#
# Clean up
#
rm -rf *.gz *.zip *.msi *.deb *.xz *.dsc

#
# Change the password if we're in an SSH session
#
if [ ! -z "$SSH_CONNECTION" ];
then
  password=$(openssl rand -base64 24)
  sudo passwd -u -d $USER
  python -c "print ('$password'+'\n')*2"  | passwd
  echo Password is $password
fi

#
# Reboot
#
while true; do
    read -p "Reboot? [yn] " yn
    case $yn in
        [Yy]* ) sudo reboot; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# #
# # Fix hostname so that it looks like...
# #
# #    ubuntu-12.10-quantal-i686
# #
# distro="$(lsb_release -si)"
# codename="$(lsb_release -sc)"
# version="$(lsb_release -sr)"
# arch="$(uname -m)"
# hostname="$distro-$version-$codename-$arch"
# hostname=${hostname,,}
# hostname="$(echo $hostname | sed 's|\.|-|')"
# sudo bash -c "echo $hostname > /etc/hostname"
