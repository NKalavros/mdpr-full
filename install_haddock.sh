#!bin/bash
sudo apt-get -yf install curl wget rar gzip tar python python-dev python-pip python3 python3-dev python3-pip git pymol freeglut3-dev libjpeg-dev libpng-dev zlib1g-dev gfortran gawk perl tcsh build-essential
sudo -H pip install setuptools wheel
sudo -H pip3 install setuptools wheel
sudo curl -L https://www.dropbox.com/s/v2n85avgnm6tohh/cns_solve_1.3_all.tar.gz?dl=0 --output cns13.tar.gz
sudo curl -L https://www.dropbox.com/s/32h76w3l4gnaxxh/x3dna-v2.4-linux-64bit.tar.gz?dl=0 --output x3dna.tar.gz
sudo curl -L https://www.dropbox.com/s/4fmks0cxcvu8pa1/foldxLinux64.tar_.gz?dl=0 --output foldx4.tar.gz
tar -zxvf x3dna.tar.gz
sudo rm -r x3dna.tar.gz
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
sudo sed -i "s/{===>} structures_1=200;/{===>} structures_1=80;/" ./protocols/run.cns
cd ..
cd haddock2.2/examples/protein-dna
haddock2.2
cp dna-rna_restraints.def run1/data/sequence
cd run1
patch -p0 -i ../run.cns.patch
haddock2.2 >> haddock.out
