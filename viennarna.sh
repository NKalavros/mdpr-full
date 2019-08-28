sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install build-essential python python-dev python3 python3-dev python-pip python3-pip
sudo -H pip install setuptools wheel numpy
sudo -H pip3 install setuptools wheel numpy
wget https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_4_x/ViennaRNA-2.4.14.tar.gz
tar -zxvf ViennaRNA-2.4.14.tar.gz
rm -r ViennaRNA-2.4.14.tar.gz
cd ViennaRNA-2.4.14
./configure --with-python3
sudo make -j 60
sudo make check
sudo make install -j 60
cd ..
