sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y install build-essential python python-dev python3 \
python3-dev python-pip python3-pip libgomp1 \
curl wget rar gzip tar git pymol freeglut3-dev \
libjpeg-dev libpng-dev zlib1g-dev gfortran gawk perl tcsh gawk \
cmake openmpi-bin openmpi-common openssh-client openssh-server \
libopenmpi2 libopenmpi-dev

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
sudo ln -s $(pwd)/* /usr/local/bin
sudo cp -r $(pwd)/forcefield ..
sudo rm /usr/local/bin/configfile.txt
sudo cp ./configfile.txt /usr/local/bin/configfile.txt
echo "alias qrnaconfig='cat /usr/local/bin/configfile.txt'" >> ~/.bashrc
echo export PATH='$PATH':$(pwd) >>~/.bashrc
echo export QRNAS_FF_DIR=$(pwd)/forcefield >>~/.bashrc
cd ..

wget --no-check-certificate https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz
tar -zxvf SimRNA_64bitIntel_Linux.tgz
rm -r SimRNA_64bitIntel_Linux.tgz
cd SimRNA_64bitIntel_Linux
sudo ln -s $(pwd)/* /usr/local/bin
sed -i -e 's/NUMBER_OF_ITERATIONS 16000000/NUMBER_OF_ITERATIONS 800000/g' config.dat
sed -i -e "s/TRA_WRITE_IN_EVERY_N_ITERATIONS 1600/TRA_WRITE_IN_EVERY_N_ITERATIONS 800/" config.dat
sudo cp -r ./data ..
cp config.dat ../config.dat
cd ..

sudo curl -L https://www.dropbox.com/s/ha7x8h09rtkmvad/x3dna-dssr?dl=0 --output x3dna-dssr
sudo chmod 777 x3dna-dssr
sudo mv ./x3dna-dssr /usr/local/bin/x3dna-dssr
sudo curl -L https://www.dropbox.com/s/v2n85avgnm6tohh/cns_solve_1.3_all.tar.gz?dl=0 --output cns13.tar.gz
sudo curl -L https://www.dropbox.com/s/32h76w3l4gnaxxh/x3dna-v2.4-linux-64bit.tar.gz?dl=0 --output x3dna.tar.gz
sudo curl -L https://www.dropbox.com/s/4fmks0cxcvu8pa1/foldxLinux64.tar_.gz?dl=0 --output foldx4.tar.gz
tar -zxvf x3dna.tar.gz
sudo rm -r x3dna.tar.gz
cd x3dna-v2.4/src
sudo make
cd ../..

cd x3dna-v2.4/bin #Dive
echo "export X3DNA=$(pwd)/.." >> ~/.bashrc
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
source ~/.bashrc
sudo ln -s $(pwd)/* /usr/local/bin/
cd ../..

tar -zxvf foldx4.tar.gz
sudo rm -r foldx4.tar.gz
sudo mv ./foldx /usr/local/bin/foldx
sudo mv ./rotabase.txt /usr/local/bin/rotabase.txt
tar -zxvf cns13.tar.gz
sudo rm -r cns13.tar.gz

git clone https://github.com/pekrau/MolScript
cd MolScript/code
mv Makefile.basic Makefile
sudo make
sudo make install
cd ../..

git clone https://NKalavros:yourpassword@github.com/NKalavros/haddock-deps.git

mv haddock-deps/run_prototype.cns .
mv haddock-deps/dna-rna_restraints_prototype.def .
mv haddock-deps/new_prototype.html .

cd haddock-deps
gunzip naccess.rar.gz
mkdir naccess
rar e -p"nac97" naccess.rar naccess
rm -r naccess.rar
cd naccess
sudo sed -i "s#f77 accall.f -o accall -O #gfortran accall.f -o accall#"  install.scr
sudo sed -i "s#                  write(4,'(a,i)')#                  write(4,'(a1,i5)')#" accall.f
sudo csh install.scr
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
cd ..

tar -zxvf profit.tar.gz
sudo rm -r profit.tar.gz
cd ProFitV3.1/src
sudo make
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
cd ../..

zcat *.Z | tar -xvf -
sudo rm -r pales.linux.tar.Z
cd pales/linux
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
cd ../..

tar -xvf MODULE_PC9.tar
rm -r MODULE_PC9.tar
cd MODULE_PC9
sudo chmod +x module
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
cd ..

tar -xvf TENSORV2_PC9.tar
rm -r TENSORV2_PC9.tar
cd TENSORV2_PC9
sudo chmod +x tensor2
echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
cd ..

tar -zxvf haddock2.2.tgz
rm -r haddock2.2.tgz
cd haddock2.2
sudo mv cns1.3/* ../../cns_solve_1.3/source
sudo mv ../haddock_configure.sh ./haddock_configure.sh
sudo bash haddock_configure.sh
source ~/.bash_profile
sudo sed -i "1773s#.*#{===>} cns_exe_1='$HADDOCK/../../cns_solve_1.3/intel-x86_64bit-linux/bin/cns';#" protocols/run.cns
sudo sed -i '1773s/\x27/\"/g' protocols/run.cns
NPROC=$(($(nproc) - 0))
sudo sed -i "s|{===>} cpunumber_1=2;|{===>} cpunumber_1=$NPROC;|" protocols/run.cns
sudo sed -i "/        ONEM = DPTRUNC(ONE) - DPTRUNC(FPEPS)/a        WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM" $HADDOCK/../../cns_solve_1.3/source/machvar.f
sudo sed -i "s/WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM/        WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM/" $HADDOCK/../../cns_solve_1.3/source/machvar.f
sudo sed -i "s/useLongJobFileNames = 0 /useLongJobFileNames = 1/" $HADDOCK/Haddock/Main/UseLongFileNames.py
sudo make
cd ../../cns_solve_1.3
sudo sed -i "s#	    setenv CNS_SOLVE '_CNSsolve_location_'#setenv CNS_SOLVE $(pwd)#" ./cns_solve_env
sudo sed -i "s|###setenv OMP_NUM_THREADS 4|setenv OMP_NUM_THREADS $NPROC|" ./cns_solve_env
sudo mv ../haddock-deps/machvar.f ./source/machvar.f
sudo sed -i "s|	CNS_SOLVE=_CNSsolve_location_| CNS_SOLVE='$(pwd)'|" ./.cns_solve_env_sh
sudo sed -i "s|###export OMP_NUM_THREADS 4|export OMP_NUM_THREADS=$NPROC|" ./.cns_solve_env_sh
source ./.cns_solve_env_sh
sudo make install
cd ../haddock-deps/haddock2.2
sudo sed -i "s/{===>} structures_0=1000;/{===>} structures_0=480;/" ./protocols/run.cns
sudo sed -i "s/{===>} structures_1=200;/{===>} structures_1=80;/" ./protocols/run.cns
sudo sed -i "s/{===>} anastruc_1=200;/{===>} anastruc_1=80;/" ./protocols/run.cns
sudo sed -i "s/{===>} crossdock=true;/{===>} crossdock=false;/" ./protocols/run.cns
sudo sed -i "s/{===>} waterrefine=200;/{===>} waterrefine=80;/" ./protocols/run.cns
sudo sed -i "s/{===>} tadfactor= 8;/{===>} tadfactor= 6;/" ./protocols/run.cns
sudo sed -i "s/{===>} w_desolv_0=1.0;/{===>} w_desolv_0=0;/" ./protocols/run.cns
sudo sed -i "s/{===>} w_desolv_1=1.0;/{===>} w_desolv_1=0;/" ./protocols/run.cns
sudo sed -i "s/{===>} w_desolv_2=1.0;/{===>} w_desolv_2=0;/" ./protocols/run.cns
cd ..

git clone https://github.com/rlabduke/MolProbity
cd MolProbity
rm install_via_bootstrap.sh
svn --quiet --non-interactive --trust-server-cert export https://github.com/rlabduke/MolProbity.git/trunk/install_via_bootstrap.sh
sudo bash ./install_via_bootstrap.sh 40
cd bin/linux
sudo ln -s $(pwd)/* /usr/local/bin
cd ../../..

git clone https://github.com/haddocking/pdb-tools
cd pdb-tools/pdbtools
sudo cp $(pwd)/* /usr/lib/python3.6
cd ../..

wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.3.tar.gz
tar -zxvf gromacs-2019.3.tar.gz
rm -r gromacs-2019.3.tar.gz
cd gromacs-2019.3
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx
sudo make -j 80
make check
sudo make install
cd ../..
