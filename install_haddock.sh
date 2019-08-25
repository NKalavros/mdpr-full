#!bin/bash
####First, install the necessary packages
###First, from the repositories (used on Linux Mint 19.1). Even though the final 4 libraries are installed, they will not be used
sudo apt-get -yf install curl wget rar gzip tar python python-dev python-pip python3 python3-dev python3-pip git pymol freeglut3-dev libjpeg-dev libpng-dev zlib1g-dev gfortran gawk perl tcsh build-essential
###Next, the elementary python packages
sudo -H pip install setuptools wheel
sudo -H pip3 install setuptools wheel
####Second, clone the repository that contains the needed packages. CNS will be downloaded separately, as it is too large for Github
###First, download CNS, 3DNA and FoldX from Dropbox
sudo curl -L https://www.dropbox.com/s/v2n85avgnm6tohh/cns_solve_1.3_all.tar.gz?dl=0 --output cns13.tar.gz
sudo curl -L https://www.dropbox.com/s/32h76w3l4gnaxxh/x3dna-v2.4-linux-64bit.tar.gz?dl=0 --output x3dna.tar.gz
sudo curl -L https://www.dropbox.com/s/4fmks0cxcvu8pa1/foldxLinux64.tar_.gz?dl=0 --output foldx4.tar.gz
##First, simply extract them. Installation will be performed later
#X3DNA 2.4 installation
tar -zxvf x3dna.tar.gz #Untar and gunzip it in one command
sudo rm -r x3dna.tar.gz #Remove the archive
cd x3dna-v2.4/bin #Dive
export X3DNA=$(pwd)/.. #Set the needed enviroment variable
export PATH=$PATH:$(pwd) #Export to path
source ~/.bashrc #Source the new bashRC
sudo ln -s $(pwd)/* /usr/local/bin/ #Use symbolic links to freely run the commands
cd ../.. #Get out
#FoldX 4 installation
tar -zxvf foldx4.tar.gz #Untar and gunzip it in one command
sudo rm -r foldx4.tar.gz #Remove the archive
sudo mv ./foldx /usr/local/bin/foldx #Move foldx executable to usr/local/bin
sudo mv ./rotabase.txt /usr/local/bin/rotabase.txt #Move rotabase.txt to /usr/local/bin
#Extract CNS, do not install it
tar -zxvf cns13.tar.gz
sudo rm -r cns13.tar.gz
###Subsequently, Molscript from github
git clone https://github.com/pekrau/MolScript #Clone
##It's installation process is pretty simple
cd MolScript/code #Dive
mv Makefile.basic Makefile #Rename the makefile
sudo make #Make
sudo make install #Make install
cd ../.. #Get out
###Next, the data from the repository. This includes HADDOCK, NACCESS, ProFit, PALES, MODULE, Tensor, DSSR, SNAP, LIGPLOT, Grace, Rasmol, FastContact. You need to enter your password instead of the placeholder
git clone https://NKalavros:2008041900141108@github.com/NKalavros/haddock-deps.git
cd haddock-deps #Get in
##First, go for NACCESS
gunzip naccess.rar.gz #Gunzip it
mkdir naccess #Make installation directory
rar e -p"nac97" naccess.rar naccess #Unrar file
rm -r naccess.rar #Remove archive
cd naccess #Dive in
sudo sed -i "s#f77 accall.f -o accall -O #gfortran accall.f -o accall#"  install.scr #Change compiler
sudo sed -i "s#                  write(4,'(a,i)')#                  write(4,'(a1,i5)')#" accall.f #Some formatting problems that are not encountered in Intel's
sudo csh install.scr #Install NACCESS (Compile)
export PATH=$PATH:$(pwd) #Export to path
cd .. #Emerge
##Next, to install ProFit
tar -zxvf profit.tar.gz #Untar and gunzip in one command
sudo rm -r profit.tar.gz #Remove archive
cd ProFitV3.1/src #Dive in to the source directory
sudo make #Make
export PATH=$PATH:$(pwd) #Export to path
cd ../.. #Emerge
##Next, to install PALES
zcat *.Z | tar -xvf - #Uncompress and untar in one command
sudo rm -r pales.linux.tar.Z #Remove archive
cd pales/linux #Dive in
export PATH=$PATH:$(pwd) #Export to path
cd ../.. #Emerge
##Next, to install Module
tar -xvf MODULE_PC9.tar #Untar
rm -r MODULE_PC9.tar #Remove archive
cd MODULE_PC9 #Dive in
sudo chmod +x module #Make executable
export PATH=$PATH:$(pwd) #Export to path
cd .. #Emerge
##Next, to install Tensor (This is the final one for now 25/6/2019 13:16 PM)
tar -xvf TENSORV2_PC9.tar #Untar
rm -r TENSORV2_PC9.tar #Remove Archive
cd TENSORV2_PC9 #Dive in
sudo chmod +x tensor2 #Make executable
export PATH=$PATH:$(pwd) #Export to path
cd .. #Emerge
##Lastly, to install HADDOCK itself and compile CNS13 with the required runtimes
tar -zxvf haddock2.2.tgz #Untar and gunzip in one command
rm -r haddock2.2.tgz #Remove archive
cd haddock2.2
sudo mv cns1.3/* ../../cns_solve_1.3/source #Move the CNS routines in order to recompile with them
#Editting the haddock_configure.sh file. The editted file is uploaded to github
sudo mv ../haddock_configure.sh ./haddock_configure.sh #Pasting the editting file in this folder
sudo bash haddock_configure.sh #Add variables to ~/.bash_profile
source ~/.bash_profile #Source it up
sudo sed -i "1773s#.*#{===>} cns_exe_1='$HADDOCK/../../cns_solve_1.3/intel-x86_64bit-linux/bin/cns';#" protocols/run.cns #Make sure it is pointing to the correct directory for CNS
sudo sed -i '1773s/\x27/\"/g' protocols/run.cns #Single to double quotes
NPROC=$(($(nproc)-2)) #Set the number of threads variable
sudo sed -i "s|{===>} cpunumber_1=2;|{===>} cpunumber_1=$NPROC;|" protocols/run.cns #Up the processors
#Some more debugging for CNS itself now.
sudo sed -i "/        ONEM = DPTRUNC(ONE) - DPTRUNC(FPEPS)/a        WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM" $HADDOCK/../../cns_solve_1.3/source/machvar.f
sudo sed -i "s/WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM/        WRITE (6,'(I6,E10.3,E10.3)') I, ONEP, ONEM/" $HADDOCK/../../cns_solve_1.3/source/machvar.f
#These ones seem to cause no apparent problem though. Removing these for a test
#sudo sed -i "s/      PARAMETER (MXFPEPS2=1024)/      PARAMETER (MXFPEPS2=2048)/" $HADDOCK/../../cns_solve_1.3/source/machvar.inc
#sudo sed -i "s/      PARAMETER (MXRTP=20000)/      PARAMETER (MXRTP=4000)/" $HADDOCK/../../cns_solve_1.3/source/rtf.inc
#Lastly, debugging for long filenames in HADDOCK $HADDOCK/Haddock/Main/UseLongFileNames.py
sudo sed -i "s/useLongJobFileNames = 0 /useLongJobFileNames = 1/" $HADDOCK/Haddock/Main/UseLongFileNames.py
sudo make #Make for all the tools
#Recompiling CNS with the available libraries
cd ../../cns_solve_1.3 #Go straight to CNS
sudo sed -i "s#	    setenv CNS_SOLVE '_CNSsolve_location_'#setenv CNS_SOLVE $(pwd)#" ./cns_solve_env #Set the enviroment variable to the correct directory
NPROC=$(($(nproc)-2)) #Set the number of threads variable
sudo sed -i "s|###setenv OMP_NUM_THREADS 4|setenv OMP_NUM_THREADS $NPROC|" ./cns_solve_env #Set the number of threads as the number of processors -2
sudo mv ../haddock-deps/machvar.f ./source/machvar.f
#Moving comments upwards because of issues with csh. #Source the file with the variables #Install it and change the .sh script to source it more easily into your actual shell
csh
source cns_solve_env
sudo make install
exit
sudo sed -i "s|	CNS_SOLVE=_CNSsolve_location_| CNS_SOLVE='$(pwd)'|" ./.cns_solve_env_sh
sudo sed -i "s|###export OMP_NUM_THREADS 4|export OMP_NUM_THREADS=$NPROC|" ./.cns_solve_env_sh
source ./.cns_solve_env_sh
cd ../haddock-deps/haddock2.2 #Move back to HADDOCK
#After being done, pass all paths to profile, just to be sure. Otherwise, they will die with the closing of the terminal
cd .. #Emerge
IFS=':' read -ra ADDR <<< "$PATH"
for i in "${ADDR[@]}"; do     echo "export PATH=$i:"'$PATH' >>~/.bash_profile; done
#Delete and sort for cleaniness
sort ~/.bash_profile | uniq >> ~/.bash_profile2
#If you ever close the terminal, just rerun
source ~/.bash_profile2
#Run the protein DNA example
cd haddock2.2/examples/protein-dna
haddock2.2
cp dna-rna_restraints.def run1/data/sequence
cd run1
patch -p0 -i ../run.cns.patch
haddock2.2 >> haddock.out
