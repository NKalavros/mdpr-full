sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential
wget http://genesilico.pl/QRNAS/QRNAS.tar.gz
tar -xvzf QRNAS.tar.gz
rm -r QRNAS.tar.gz
cd QRNAS
sudo make parallel
echo export PATH='$PATH':$(pwd) >>~/.bashrc
echo export QRNAS_FF_DIR=$(pwd)/forcefield >>~/.bashrc
source ~/.bashrc
	
