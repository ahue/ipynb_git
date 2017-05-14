#!/bin/sh

# 1. Preparations
# Activate Windows Linux Subsystem: https://msdn.microsoft.com/en-us/commandline/wsl/install_guide
# Update Windows (fixes some issues in the WSL): https://www.microsoft.com/de-de/windows/features

# 2. Configure WSL
# Install anaconda3
# https://docs.continuum.io/anaconda/install-linux.html
# permanently add to you path using profile http://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux#14638025 (I added it to .bashrc, profile did not work for some reason)
wget https://repo.continuum.io/archive/Anaconda3-4.3.1-Linux-x86_64.sh
bash Anaconda3-4.3.1-Linux-x86_64.sh 
rm Anaconda3-4.3.1-Linux-x86_64.sh

# install pandoc
sudo apt-get install pandoc -y

# fix pandoc on wsl
# https://www.scivision.co/pandoc-windows-subsystem-for-linux-timer-create-not-implemented-error/
echo "alias pandoc='pandoc +RTS -V0 -RTS'" >> ~/.bash_aliases

# install rst2ipynb
pip install rst2ipynb

# update notedown
pip install https://github.com/aaren/notedown/tarball/master --upgrade

