sudo apt-get update
sudo apt-get -y install openmpi-bin openmpi-common openssh-client openssh-server libopenmpi2 libopenmpi-dev
wget ftp://ftp.gromacs.org/pub/gromacs/gromacs-2019.3.tar.gz
tar -zxvf gromacs-2019.3.tar.gz
rm -r gromacs-2019.3.tar.gz
cd gromacs-2019.3
mkdir build
cd build
cmake .. -DGMX_FFT_LIBRARY= fftw3 -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DGMX_MPI=on -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DGMX_GPU=on DCUDA_TOOLKIT_ROOT_DIR=/
sudo make -j 100
sudo make check
sudo make install
source /usr/local/gromacs/bin/GMXRC