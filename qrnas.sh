sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential
wget http://genesilico.pl/QRNAS/QRNAS.tar.gz
tar -xvzf QRNAS.tar.gz
rm -r QRNAS.tar.gz
cd QRNAS
sudo make parallel
sudo sed -i "s/#WRITEFREQ  1000/WRITEFREQ  1000/" configfile.txt
sudo sed -i "s/STEPS     5000   # Maximal number of steps; by default 100000/STEPS     10000/" configfile.txt
sudo sed -i "s/NUMTHREADS  08      # Number of threads (parallel builds only!); by default 4/NUMTHREADS  80/" configfile.txt
sudo cp ./configfile.txt /usr/local/bin/configfile.txt
echo "alias qrnaconfig="cat /usr/local/bin/configfile.txt"" >> ~/.bashrc
echo export QRNAS_FF_DIR=$(pwd)/forcefield >>~/.bashrc
source ~/.bashrc
cd ..   
	
