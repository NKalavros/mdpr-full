sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install libgomp1
wget --no-check-certificate https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz
tar -zxvf SimRNA_64bitIntel_Linux.tgz
rm -r SimRNA_64bitIntel_Linux.tgz
cd SimRNA_64bitIntel_Linux
sudo ln -s $(pwd)/* /usr/local/bin
#Running a test example
echo "CGCUUCAUAUAAUCCUAAUGAUAUGGUUUGGGAGUUUCUACCAAGAGCCUUAAACUCUUGAUUAUGAAGUG" > test_seq.fa
echo "(((((((((...((((((.........))))))........((((((.......))))))..)))))))))" > test_seq_secstr.fa
sed -i -e 's/NUMBER_OF_ITERATIONS 16000000/NUMBER_OF_ITERATIONS 160000/g' config.dat
##Restraints
#The WELL restraint (a single line in the restraints file):
#WELL      atom_1_id  atom_2_id    min_dist  max_dist  weight
##Config options
#BONDS_WEIGHT        1.0
#ANGLES_WEIGHT       1.0
#TORS_ANGLES_WEIGHT 0.0
#ETA_THETA_WEIGHT   0.4
#SECOND_STRC_RESTRAINTS_WEIGHT 1.0
#FRACTION_OF_NITROGEN_ATOM_MOVES 0.10
#FRACTION_OF_ONE_ATOM_MOVES      0.45
#FRACTION_OF_TWO_ATOMS_MOVES     0.44
#FRACTION_OF_FRAGMENT_MOVES      0.01
#LIMITING_SPHERE_RADIUS 41.5
#LIMITING_SPHERE_WEIGHT 0.25
#This took 126 seconds in simRNA
for i in {1..2};
do
    ./SimRNA -s test_seq.fa -S test_seq_secstr.fa -c config.dat -R 1000 -E 7 -o fold_test_seq_$i >& fold_test_seq_$i.log & 
done
#When simRNA was run with replicates (As recommended), using only 10 replicates, the program needed 266 seconds (due to parallelization).
#Clustering is almost instant
cat fold_test_seq_?_??.trafl > fold_test_seq_all.trafl
./clustering fold_test_seq_all.trafl 0.01 2.5 >& fold_test_seq_all.log
for i in fold_test_seq_all_thrs2.50A*.trafl;
do
    echo $i
    SimRNA_trafl2pdbs fold_test_seq_1_01-000001.pdb $i 1 AA
done
mv fold_test_seq_1_01-000001.pdb final_seq.pdb
