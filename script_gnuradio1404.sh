#!/bin/bash
# Dockerfile ported to setup script by Adam Schoenwald
# Docker file located at https://github.com/radioML/dockerRML
# Script to set up Ubuntu 14.04 LTS desktop install on VMWare.
# After installing prerequiisits, this will generate radioML dataset.
# Make sure there is enough memory, vmware failed at 1024. I set it to 3072MB Ram and 2 CPUS and it worked. No other configs tried.
sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade
sudo apt-get install -y python-software-properties software-properties-common 
sudo apt-get -y install \
	python-pip git openssh-server vim emacs screen tmux locate \
	python-matplotlib python-scipy python-numpy \
	python-sklearn python-sklearn-doc python-skimage \
	python-skimage-doc python-scikits-learn python-scikits.statsmodels \
	python-opencv gimp \
	firefox evince audacity meld \
	xfwm4 xfce4 \
	autotools-dev autoconf sudo wireshark gdb

cd /tmp		   
sudo pip install --upgrade pip
#Apperently I don't need this. Tried without and still works. Added for ssl error
#sudo pip install requests[security]
sudo pip install --upgrade ipython[all]
sudo pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git
sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0-cp27-none-linux_x86_64.whl
sudo pip install --upgrade git+https://github.com/fchollet/keras.git
sudo pip install --upgrade seaborn tqdm

sudo pip install --upgrade git+https://github.com/gnuradio/pybombs.git
mkdir ~/gr/
cd ~/gr/
sudo pybombs prefix init .
sudo pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git 
sudo pybombs recipes add gr-etcetera git+https://github.com/gnuradio/gr-etcetera.git
# gr-mediatools was missing from script in docker file
sudo pybombs install gnuradio gr-burst gr-pyqt gr-pcap gr-mapper gr-analysis gr-mediatools

mkdir ~/src/
cd ~/src/
git clone https://github.com/Theano/Theano.git
# already installed via pip
#cd Theano
#python setup.py build 
#sudo python setup.py install

cd ~/src
git clone https://github.com/tensorflow/tensorflow.git
# already installed via pip

cd ~/src
git clone https://github.com/fchollet/keras.git
# already installed via pip

sudo pip install networkx
sudo apt-get install -y python-numpy python-dev cmake zlib1g-dev libjpeg-dev xvfb libav-tools xorg-dev python-opengl libboost-all-dev libsdl2-dev swig pypy-dev

cd ~/src/
git clone https://github.com/PyOpenPNL/OpenPNL.git 
cd OpenPNL 
./autogen.sh 
./configure CFLAGS='-g -O2 -fpermissive -w' CXXFLAGS='-g -O2 -fpermissive -w' 
make -j4 
sudo make install
cd ~/src/
git clone https://github.com/PyOpenPNL/PyOpenPNL.git 
cd PyOpenPNL 
python setup.py build 
sudo python setup.py install
cd ~/src/
git clone https://github.com/osh/kerlym.git 
cd kerlym 
python setup.py build 
sudo python setup.py install


#Set dimension in keras to work with radioML script
perl -pi -e 's/tf/th/g' ~/.keras/keras.json

mkdir ~/radioML
cd ~/radioML
git clone https://github.com/radioML/dataset.git
cd ~/radioML/dataset/
git clone https://github.com/radioML/source_material.git
source ~/gr/setup_env.sh
# Need to launch gui to configure ~/.gnuradio/ environment, otherwise error on script. Just close gui when it opens
gnuradio-companion
cd ~/radioML/dataset/
python generate_RML2016.10a.py

