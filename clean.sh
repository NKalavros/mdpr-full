mv 0.fasta ..
mv crp_monomer.pdb ..
mv run_prototype.cns ..
mv new_prototype.html ..
mv dna-rna_restraints_prototype.def ..



rm *.fasta
rm *.secstr
rm *.simrna*
rm *.trafl
rm *ss_detected
rm *qrna*
rm *rna.log
rm *.pdb


rm *.secfromtert
rm *.pdb.haddock
rm *.def
rm *.cns

find -maxdepth 1 -type d -name "run*" -exec rm -rf {} \;

mv ../0.fasta .
mv ../crp_monomer.pdb .
mv ../run_prototype.cns .
mv ../new_prototype.html .
mv ../dna-rna_restraints_prototype.def .
