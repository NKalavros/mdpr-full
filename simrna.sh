sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install libgomp1
wget --no-check-certificate https://ftp.users.genesilico.pl/software/simrna/version_3.20/SimRNA_64bitIntel_Linux.tgz
tar -zxvf SimRNA_64bitIntel_Linux.tgz
rm -r SimRNA_64bitIntel_Linux.tgz
cd SimRNA_64bitIntel_Linux
sudo ln -s $(pwd)/* /usr/local/bin
echo "CGCUUCAUAUAAUCCUAAUGAUAUGGUUUGGGAGUUUCUACCAAGAGCCUUAAACUCUUGAUUAUGAAGUG" > test_seq.fa
echo "(((((((((...((((((.........))))))........((((((.......))))))..)))))))))" > test_seq_secstr.fa
sed -i -e 's/NUMBER_OF_ITERATIONS 16000000/NUMBER_OF_ITERATIONS 160000/g' config.dat
for i in {1..10};
do
    ./SimRNA -s test_seq.fa -S test_seq_secstr.fa -c config.dat -R 1000 -E 8 -o fold_test_seq_$i >& fold_test_seq_$i.log & 
done
cat fold_test_seq_?_??.trafl > fold_test_seq_all.trafl
./clustering fold_test_seq_all.trafl 0.01 2.5 >& fold_test_seq_all.log
for i in fold_test_seq_all_thrs2.50A*.trafl;
do
    echo $i
    SimRNA_trafl2pdbs fold_test_seq_1_01-000001.pdb $i 1 AA
done
secstr=`cat test_seq_secstr.fa`
qrnaconfig >> qrnaconfig.txt
sudo sed -i "s/#SECSTRUCT   (((....)))/SECSTRUCT $secstr/" qrnaconfig.txt
QRNA -i fold_test_seq_1_01-000001.pdb -o final_seq.pdb -c qrnaconfig.txt
rm *test*
