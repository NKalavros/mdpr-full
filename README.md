# Mutate Dock Predict Repeat *YEAH AS IF THAT IS THE CORRECT ORDER ΣΤΟΥΦΙΔ*

A repository that hosts the necessary scripts to install and run the **MPDR** routine created by iGEM Athens 2019. Obviously wrongly named. MPDR stands for Mutate, Predict, Dock Repeat.

## What does this repository contain?

This repository contains scripts to install the necessary programs for the MPDR pipeline. More specifically, those programs are:
1. [ViennaRNA 2.4.14 (RNA secondary structure prediction)](https://www.tbi.univie.ac.at/RNA/),
2. [SimRNA 3.2 (RNA tertiary structure prediction)](http://genesilico.pl/software/stand-alone/simrna),
3. [QRNAS 0.3 (RNA Structure refinement)](http://genesilico.pl/software/stand-alone/qrnas),
4. [HADDOCK 2.2 (Protein RNA docking)](https://haddock.science.uu.nl/),
5. [GROMACS 2019.3 (Molecular Dynamics Simulations)](http://manual.gromacs.org/documentation/).

It also contains the files that we used to perform our proof-of-concept attempt of the pipeline for the iGEM Competition. Namely, we have included:

 * [0.fa (RNA aptamer for CRP, taken from Aptagen's Aptaindex)](https://www.aptagen.com/aptamer/454/c-reactive-protein). The RNA aptamer sequence was first discovered in this [publication](https://www.ncbi.nlm.nih.gov/pubmed/18066708).
 * [crp.pdb (Human C Reactive Protein structure, taken from the PDB)](http://www.rcsb.org/structure/3L2Y). The protein was crystallised and the results were made public in this [publication](https://onlinelibrary.wiley.com/doi/epdf/10.1002/jmr.1090?referrer_access_token=sCYf1bjtd5G3z-Fs9O5ynk4keas67K9QMdWULTWMo8NPWaA9ORSiI17d0BpvTifVHxZkwXwvCzEhmceJ7stFO0NuRjCXufzUtqKZ24G6rqaKDHgM0tCLQz3d-BVg64eRPVkHgwVozjfwmMshYhfwRw%3D%3D).

##How do you run this?

First, let it be known that this repository and the scripts hosted within assume (yes, they are conscious) that you have admin priviledges in your computer and therefore can use sudo. They also assume, in their infinite wisdom, that you have access to a cluster of 80 cores. **Notes will be added later on as to how to change those two assumptions.** Needless to say, for such a computationally intensive pipeline, the more cores you have the merrier.

First, begin by installing all the programs that will be needed as follows:
1. ` sudo bash viennarna.sh `
2. ` sudo bash qrnas.sh `
3. ` sudo bash SimRNA.sh `
4. ` sudo bash gromacs.sh `

Lastly you will need to install HADDOCK using:
` sudo bash install_haddock.sh `
Right now this script is impossible for you to use, as it depends on one of my other repositories (haddock-deps), which is privated. The reason that repository is privated is because many of the programs that are used as part of HADDOCK's routines are free only for academic use and I do not have the right to redistribute them. **I will remake the scripts in order for the haddock-deps repository to be unneeded, however, it will still require you to place the programs in the working directory**. Those programs include, but are not necessarily limited to:

* [CNS (Crystallography and NMR System) *needs license and academic emial*](https://www.mrc-lmb.cam.ac.uk/public/xtal/doc/cns/cns_1.3/main/frame.html)
* [NACCESS *email the author*](http://wolf.bms.umist.ac.uk/naccess)
* [PROFIT *Sign simple license in website*](http://www.bioinf.org.uk/software/)
* [TENSORV2 *Sign simple license in website*](http://www.ibs.fr/research/scientific-output/software/tensor/?lang=en)
* [MODULE *Sign simple license in website*](http://www.ibs.fr/research/scientific-output/software/module/?lang=en)
* [X3DNA *Become member of a forum*](http://forum.x3dna.org/site-announcements/download-instructions/)
* [PALES *Easy and simple to download, thank the heavens*](https://spin.niddk.nih.gov/bax/software/PALES/index.html)

I apologise for this inconvenience. Right now the script needs you to be a collaborator in that private repository to download those programs.

Furthermore, this repository contains the driver scripts needed to run the genetic algorithm. Those are in the form of python files (.py) and Jupyter Notebook files (.ipnyb).

Lastly, since not many of us have access to clusters, this pipeline was run on a Google Cloud VM, using the free credits generously provided by google. A script to create a VM of those specs is provided (open_vm.sh).

Next step:
* Describe the pipeline
* Add examples with pictures
