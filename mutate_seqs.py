#!/usr/bin/env python
# coding: utf-8

# In[92]:


import os
import sys
import numpy as np
sys.path.append("/usr/local/lib/python3.6/site-packages/RNA")
import _RNA as RNA
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
    print("This is fasta max", fasta_max) #Sanity checks
    print("This is parent fasta",parent_fasta) #More sanity checks
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


# In[27]:




