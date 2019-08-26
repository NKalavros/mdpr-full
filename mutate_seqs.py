#!/usr/bin/env python
# coding: utf-8

# In[11]:


#Importing the needed packages
import os
from subprocess import call
import sys
sys.path.append("/usr/local/lib/python3.6/site-packages/RNA")
import numpy as np
import _RNA as RNA
import time
from multiprocessing import Pool
#Get the current working directory
cwd = os.getcwd()
#Bases we have, the base_dict and its probability distribution
bases = np.array(['A', 'U', 'G', 'C']) #Dictionary
base_dict = {'A': 0, 'U': 1, 'G': 2, 'C': 3} #Str --> Idx
# probability distribution, ATGC, symmetric and normalized row-sum=1 and col-sum=1
prob_distrib = np.array([[0.8, 0.05, 0.1, 0.05],
                         [0.05, 0.8, 0.05, 0.1],
                         [0.1, 0.05, 0.8, 0.05],
                         [0.05, 0.1, 0.05, 0.8]])
fasta_seqs = [] #Get the existing FASTA sequences
fasta_filenames = [] #Get their filenames
fasta_max = [] #Get the max index of the filenames, in order to not calculate more things than needed

for filename in os.listdir(cwd): #Iterate over all files in directory
    if filename.endswith(".fasta"): #Choose only fasta files
        fasta_filenames.append(filename) #Append filenames
        fasta_idx = filename.replace(".fasta","")
        fasta_secstr_filename = fasta_idx + ".secstr"
        with open(filename,"r+") as f: #Open them
            fasta_seqs.append(f.read().splitlines()[1]) #Obtain sequences
        if fasta_secstr_filename not in os.listdir(cwd): #If their secondary structure file is not in the directory
            with open(fasta_secstr_filename,"w") as f: #Create it
                (ss, mfe) = RNA.fold(fasta_seqs[-1]) #Obtain the RNA structure using RNAfold
                f.write(">" + str(fasta_idx) + " " + str(mfe))
                f.write("\n")
                f.write(ss)
                
for i in range(len(fasta_filenames)): #Iterate over the filenames
    fasta_max.append(int(fasta_filenames[i].replace(".fasta",""))) #Get the indices each time
fasta_max = max(fasta_max) #Obtain the maximum index
original_parent = fasta_max
for i in range(fasta_max+1,fasta_max + 10): #Iterate over the maximum indices, plus 10 more
    if i - 10 < original_parent: #If there are less than 10 seqs, get the highest index
        parent_fasta = original_parent #The new fasta that will be loaded now has the higher index
        fasta_max = fasta_max + 1 #The max index of the files is therefore raised by one, as a new file will be created
    else: #Else
        parent_fasta = i - 10 #Since at most ten sequences are created from ten parents (1 per parent), load the 10th plate
        fasta_max = fasta_max + 1 #The max index of the files is therefore raised by one, as a new file will be created
    #print("This is fasta max", fasta_max) #Sanity checks
    #print("This is parent fasta",parent_fasta) #More sanity checks
    fasta_filename = str(parent_fasta) + ".fasta" #Create the actual fasta filename
    with open(fasta_filename,"r") as f: #Read the file
        aptamer = f.read().splitlines()[1] #Obtain the sequence
    mutated_seq = "" #Empty string that will contain the new sequence
    mutation_matrix = prob_distrib #Local scope variable, just to be sure that we are causing no change
    number_of_mutations = 0 #Flag to keep the number of mutation
    index_to_start_mutating_from = np.random.randint(0,len(aptamer)) #Create the starting index
    for base in aptamer[index_to_start_mutating_from:]: #Index the sequence
        new_base =  np.random.choice(bases, p = prob_distrib[base_dict[base]]) #Create the new base
        if base != new_base: #Implement scaling mutation rate, if the new base is different
            number_of_mutations += 1 #Increasing the number of mutations
            diag = mutation_matrix[np.diag_indices_from(mutation_matrix)] #Store diagonal
            mutation_matrix = mutation_matrix/2 #Scale down the matrix
            #Increase the diagonal probability to make sure that the probability distribution does not stay the same
            #And that it adds up to 1. Taking advantage of symmetry, this is achieved in the next line
            mutation_matrix[np.diag_indices_from(mutation_matrix)] = diag + np.sum(mutation_matrix,axis = 0) - mutation_matrix[0,0]
        mutated_seq += new_base #Add the new base to the sequence
    mutated_seq = aptamer[0:index_to_start_mutating_from] + mutated_seq #Create the full mutated seq
    (ss, mfe) = RNA.fold(mutated_seq) #Calculate the secondary structure
    fasta_max_filename = str(fasta_max) + ".fasta" #Create new filenames
    fasta_max_secstr_filename = str(fasta_max) + ".secstr" #Same for the secondary structure file
    with open(fasta_max_filename,"w+") as f: #Open up a new file
        f.write(">" + str(fasta_max) + " parent: " + str(parent_fasta)) #Write the index and the parent
        f.write("\n") #Write a newline
        f.write(mutated_seq) #Write the actual sequence
    with open(fasta_max_secstr_filename,"w+") as f: #Do the exact same for the secondary structure file
        f.write(">" + str(fasta_max) + " " + str(mfe) + " parent: " + str(parent_fasta)) #Write index, minimal folding energy and parent
        f.write("\n")
        f.write(ss)


# In[13]:


#Lets write a function for this
def rna_tertiary_structure_prediction(filename):
    with open(filename + "mpdr-rna.log","w") as main_logfile:
        fasta_idx = filename.replace(".fasta","") #Get index
        fasta_seq_filename = fasta_idx + ".fasta"
        fasta_seq_simrna_filename = fasta_idx + "fasta.simrna" #Create dummy file for simRNA
        fasta_secstr_filename = fasta_idx + ".secstr" #Get secondary structure (it must exist)
        fasta_secstr_simrna_filename = fasta_idx + ".secstr.simrna"
        fasta_terstr_filename = fasta_idx + ".pdb.simrna" #Get tertiary structure filename (will be created)
        fasta_terstr_logfile_filename = fasta_idx + "tertiary_pred.log.simrna" #Create a logfile for the tertiary structure prediction
        fasta_clustering_logfile_filename = fasta_idx + "clustering.log.simrna" #Create a logfile for the clustering procedure
        with open(fasta_seq_filename,"r") as f1: #Open up the fasta filename
            seq = f1.read().splitlines()[1] #Read the sequence
            with open(fasta_seq_simrna_filename,"w") as f2: #Open up the new SimRNA compliant fasta file
                f2.write(seq) #Write the sequence
        with open(fasta_secstr_filename,"r") as f1: #Repeat for secondary structure prediction
            secstr = f1.read().splitlines()[1]
            with open(fasta_secstr_simrna_filename,"w") as f2:
                f2.write(secstr)
        #Sanity check message
        main_logfile.write("Performing tertiary structure prediction for: "+ fasta_seq_filename + "\n" + "Using a secondary structure file: " + fasta_secstr_filename + "\n" + "And outputting the results in: " + fasta_terstr_filename + "\n" + "Using the following logfile: " + fasta_terstr_logfile_filename)
        main_logfile.flush()
        start = time.time()
        if fasta_terstr_filename not in os.listdir(cwd): #If that name doesn't exist
            with open(fasta_terstr_logfile_filename,"w") as log: #Open the logfile
                args = ["SimRNA","-E","8","-s",fasta_seq_simrna_filename,"-S",fasta_secstr_simrna_filename,"-c","config.dat","-o",fasta_terstr_filename]
                call(args,stdout = log) #Calling the terminal command
            main_logfile.write("Initial structure prediction finished, performing clustering.")
            main_logfile.flush()
            with open(fasta_idx + ".for_clustering.simrna","w") as f1: #Open the file for clustering
                for filename in sorted(os.listdir(cwd)): #Iterate over the directory
                    if filename.startswith(fasta_idx) and filename.endswith(".trafl"): #If there are trafl files
                        print("Found a replicate")
                        with open(filename,"r") as f2: #Read them in
                            f1.write(f2.read()) #Paste them in a cat way
            angstrom_cutoff = "4.4"
            fraction_to_cluster = "0.01"
            main_logfile.write("Clustering the top " + fraction_to_cluster + " of each replicate using a" + angstrom_cutoff + "Angstrom cutoff")
            main_logfile.flush()
            with open(fasta_clustering_logfile_filename,"w") as log: #Create a log file
                args = ["clustering",fasta_idx + ".for_clustering.simrna","0.01","4.4"] #Arguments for clustering
                call(args,stdout = log) #Perform the actual clustering
            main_logfile.write("Refining the PDB file, using the clustering runs")
            main_logfile.flush()
            for filename in sorted(os.listdir(cwd)): #Iterate one last time over the directory
                if "4.4" in filename: #Get only the cluster files
                    if "04" in filename:
                        break
                    args = ["SimRNA_trafl2pdbs", fasta_terstr_filename + "_01-000001.pdb", filename, "1","AA"] #Create list of args
                    call(args) #Call the actual command
            QRNAS_filename = fasta_idx + "for_clustering_thrs4.40A_clust01-000001_AA.pdb"
            qrnas_start = time.time()
            main_logfile.write("SimRNA subroutine complete, continuing with QRNAs.It took:", str(round((time.time() - start),0)),"seconds for",fasta_idx)
            main_logfile.flush()
            with open(fasta_idx + "qrnaconfig.txt","w") as f1: #Open up a new qrnaconfig for the specific case
                with open("/usr/local/bin/configfile.txt","r") as f2: #Open the original qrnaconfig
                    original_config_file = f2.read().splitlines() #Split lines
                    with open(fasta_secstr_simrna_filename,"r") as f3: #Obtain secondary structure
                        new_secstr = f3.read() #Save it in a variable
                        original_config_file[-3] = "SECSTRUCT   " + new_secstr #Paste it in the new config file
                        f1.write("\n".join(original_config_file)) #Save the new configfile
            with open(fasta_idx +"qrna.logfile","w") as log:
                args = ["QRNA","-i",QRNAS_filename,"-c",fasta_idx + "qrnaconfig.txt","-o",fasta_idx + ".pdb"] #Set the arguments
                call(args,stdout = log)
            main_logfile.write("QRNAS is complete. It took:", str(round((time.time() - start),0)), "seconds for",fasta_idx)
            main_logfile.flush()
            main_logfile.write("The whole subroutine is complete, it took:",str(time.time() - start),"seconds for",fasta_idx) #Time taken
            main_logfile.flush()
    return(fasta_idx)
            
#Now all the secondary structure stuff is done, time to reiterate over the directory to calculate the tertiary structure
num_threads = 10
filenames = []
for filename in sorted(os.listdir(cwd)): #Iterate over files in directory
    if filename.endswith(".fasta"): #If they are fasta
        filenames.append(filename)
print("These are the filenames for which tertiary structure prediction will be performed")
print(" ".join(filenames))
with Pool(num_threads) as pool:
    pool.map(rna_tertiary_structure_prediction,filenames)


# In[ ]:




