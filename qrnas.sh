sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential
wget http://genesilico.pl/QRNAS/QRNAS.tar.gz
tar -xvzf QRNAS.tar.gz
rm -r QRNAS.tar.gz
cd QRNAS
sudo make parallel
sudo sed -i "s/#WRITEFREQ  1000/WRITEFREQ  1000/" configfile.txt
sudo sed -i "s/STEPS     5000/STEPS     10000/" configfile.txt
sudo sed -i "s/NUMTHREADS  08/NUMTHREADS  08/" configfile.txt
sudo sed -i "s/#HBONDS     0/HBONDS     0/" configfile.txt
sudo sed -i "s/#SSDETECT   0/SSDETECT   0/" configfile.txt
sudo cp -r $(pwd)/* /usr/local/bin
sudo cp -r $(pwd)/forcefield ..
sudo rm /usr/local/bin/configfile.txt
echo "alias qrnaconfig='cat /usr/local/bin/configfile.txt'" >> ~/.bashrc
echo export PATH='$PATH':$(pwd) >>~/.bashrc
echo export QRNAS_FF_DIR=$(pwd)/forcefield >>~/.bashrc
cd ..
