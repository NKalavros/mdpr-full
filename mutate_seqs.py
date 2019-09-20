#!/usr/bin/env python
# coding: utf-8
import sys
#Add some directories to the path
sys.path.append("/usr/local/lib/python3.6/site-packages/RNA") #Import ViennaRNA
sys.path.append("/usr/local/bin/") #Import files from user local bin

#Importing the needed packages
import os
import argparse
import shutil
import pprint
import shlex
import subprocess
import numpy as np
from math import floor
import _RNA as RNA
import time
from multiprocessing import Pool
from concurrent.futures import ProcessPoolExecutor
from functools import partial

####Make the mutation into a function
def get_max_index():
    fasta_max = [] #Get the max index of the filenames, in order to not calculate more things than needed
    for filename in os.listdir(cwd): #Iterate over all files in directory
        if filename.endswith(".fasta"): #Choose only fasta files
            fasta_max.append(int(filename.replace(".fasta",""))) #Append filenames
    fasta_max = max(fasta_max) #Obtain the maximum index
    return(fasta_max)

def mutate_seq_and_get_secondary_structure(filename,fasta_max):
    #Bases we have, the base_dict and its probability distribution
    bases = np.array(['A', 'U', 'G', 'C']) #Dictionary
    base_dict = {'A': 0, 'U': 1, 'G': 2, 'C': 3} #Str --> Idx
    # probability distribution, ATGC, symmetric and normalized row-sum=1 and col-sum=1
    mutation_matrix = np.array([[0.8, 0.05, 0.1, 0.05],
                             [0.05, 0.8, 0.05, 0.1],
                             [0.1, 0.05, 0.8, 0.05],
                             [0.05, 0.1, 0.05, 0.8]])
    parent_fasta = filename.replace(".fasta","")
    new_fasta_idx = str(int(fasta_max)+1)
    fasta_secstr_filename = new_fasta_idx + ".secstr"
    with open(filename,"r+") as f: #Open them
        fasta_seq = f.read().splitlines()[1] #Obtain sequences
    mutated_seq = "" #Empty string that will contain the new sequence
    number_of_mutations = 0 #Flag to keep the number of mutation
    index_to_start_mutating_from = np.random.randint(0,len(fasta_seq)) #Create the starting index
    for base in fasta_seq[index_to_start_mutating_from:]: #Index the sequence
        new_base =  np.random.choice(bases, p = mutation_matrix[base_dict[base]]) #Create the new base
        if base != new_base: #Implement scaling mutation rate, if the new base is different
            number_of_mutations += 1 #Increasing the number of mutations
            diag = mutation_matrix[np.diag_indices_from(mutation_matrix)] #Store diagonal
            mutation_matrix = mutation_matrix/2 #Scale down the matrix
            #Increase the diagonal probability to make sure that the probability distribution does not stay the same
            #And that it adds up to 1. Taking advantage of symmetry, this is achieved in the next line
            mutation_matrix[np.diag_indices_from(mutation_matrix)] = diag + np.sum(mutation_matrix,axis = 0) - mutation_matrix[0,0]
        mutated_seq += new_base #Add the new base to the sequence
    mutated_seq = fasta_seq[0:index_to_start_mutating_from] + mutated_seq #Create the full mutated seq    
    (ss, mfe) = RNA.fold(mutated_seq) #Calculate the secondary structure
    new_fasta_filename = str(new_fasta_idx) + ".fasta" #Create new filenames
    new_fasta_secstr_filename = str(new_fasta_idx) + ".secstr" #Same for the secondary structure file
    with open(new_fasta_filename,"w+") as f: #Open up a new file
        f.write(">" + str(new_fasta_idx) + " parent: " + str(parent_fasta)) #Write the index and the parent
        f.write("\n") #Write a newline
        f.write(mutated_seq) #Write the actual sequence
    with open(new_fasta_secstr_filename,"w+") as f: #Do the exact same for the secondary structure file
        f.write(">" + str(new_fasta_idx) + " " + str(mfe) + " parent: " + str(parent_fasta)) #Write index, minimal folding energy and parent
        f.write("\n")
        f.write(ss)
    return(None)

#Lets write a function for this
def rna_tertiary_structure_prediction(filename,angstrom_cutoff = "4.4",fraction_to_cluster = "0.01"):
    
    #if sequence_length is not None:
    #    angstrom_cutoff = str(sequence_length/10)
    fasta_idx = filename.replace(".fasta","") #Get index
    fasta_seq_filename = fasta_idx + ".fasta"
    fasta_seq_simrna_filename = fasta_idx + "fasta.simrna" #Create dummy file for simRNA
    fasta_secstr_filename = fasta_idx + ".secstr" #Get secondary structure (it must exist)
    fasta_secstr_simrna_filename = fasta_idx + ".secstr.simrna"
    fasta_terstr_filename = fasta_idx + ".pdb.simrna" #Get tertiary structure filename (will be created)
    with open(fasta_idx + "mpdr-rna.log","w") as main_logfile:
        with open(fasta_seq_filename,"r") as f1: #Open up the fasta filename
            seq = f1.read().splitlines()[1] #Read the sequence
            with open(fasta_seq_simrna_filename,"w") as f2: #Open up the new SimRNA compliant fasta file
                f2.write(seq) #Write the sequence
        with open(fasta_secstr_filename,"r") as f1: #Repeat for secondary structure prediction
            secstr = f1.read().splitlines()[1]
            with open(fasta_secstr_simrna_filename,"w") as f2:
                f2.write(secstr)
        #Sanity check message
        main_logfile.write(("Performing tertiary structure prediction for: "+ fasta_seq_filename + "\n" + "Using a secondary structure file: " + fasta_secstr_filename + "\n" + "And outputting the results in: " + fasta_terstr_filename + "\n"))
        main_logfile.flush()
        start = time.time()
        if fasta_terstr_filename not in os.listdir(cwd): #If that name doesn't exist
            args = ["SimRNA","-E","8","-s",fasta_seq_simrna_filename,"-S",fasta_secstr_simrna_filename,"-c","config.dat","-o",fasta_terstr_filename]
            subprocess.call(args) #Calling the terminal command
            main_logfile.write("Initial structure prediction finished, performing clustering." + "\n")
            main_logfile.flush()
        with open(fasta_idx + ".for_clustering.simrna","w") as f1: #Open the file for clustering
            for filename in sorted(os.listdir(cwd)): #Iterate over the directory
                if filename.startswith(fasta_idx) and filename.endswith(".trafl"): #If there are trafl files
                    main_logfile.write("Found a replicate")
                    main_logfile.flush()
                    with open(filename,"r") as f2: #Read them in
                        f1.write(f2.read()) #Paste them in a cat way
        main_logfile.write(("Clustering the top " + fraction_to_cluster + " of each replicate using a " + angstrom_cutoff + " Angstrom cutoff" + "\n"))
        main_logfile.flush()
        args = ["clustering",fasta_idx + ".for_clustering.simrna",fraction_to_cluster,angstrom_cutoff] #Arguments for clustering
        subprocess.call(args) #Perform the actual clustering
        main_logfile.write("Refining the PDB file, using the clustering runs" + "\n")
        main_logfile.flush()
        for filename in sorted(os.listdir(cwd)): #Iterate one last time over the directory
            if filename.startswith(fasta_idx + ".for_clustering") and "4.4" in filename: #Get only the cluster files
                args = ["SimRNA_trafl2pdbs", fasta_terstr_filename + "_01-000001.pdb", filename, "1","AA"] #Create list of args
                subprocess.call(args) #Call the actual command
                break
        main_logfile.write("SimRNA subroutine complete, continuing with QRNAs.It took: " + str(round((time.time() - start),0)) + " seconds for " + fasta_idx + "\n")
        main_logfile.flush()
    return(fasta_idx)

def rna_tertiary_structure_refinement(filename):
    start = time.time()
    fasta_idx = filename.replace(".fasta","") #Get index
    fasta_secstr_simrna_filename = fasta_idx + ".secstr.simrna"
    with open(filename + "mpdr-rna.log","w") as main_logfile:
        with open(fasta_idx + "qrnaconfig.txt","w") as f1: #Open up a new qrnaconfig for the specific case
            with open("/usr/local/bin/configfile.txt","r") as f2: #Open the original qrnaconfig
                original_config_file = f2.read().splitlines() #Split lines
                with open(fasta_secstr_simrna_filename,"r") as f3: #Obtain secondary structure
                    new_secstr = f3.read() #Save it in a variable
                    original_config_file[-3] = "SECSTRUCT   " + new_secstr #Paste it in the new config file
                    f1.write("\n".join(original_config_file)) #Save the new configfile
        with open(fasta_idx +"qrna.logfile","w") as qrna_log:
            QRNAS_filename = fasta_idx + ".for_clustering_thrs4.40A_clust01-000001_AA.pdb"
            args = ["QRNA","-i",QRNAS_filename,"-c",fasta_idx + "qrnaconfig.txt","-o",fasta_idx + ".pdb"] #Set the arguments
            subprocess.call(args,stdout = qrna_log)
            main_logfile.write("QRNAS is complete. It took:" + str(round((time.time() - start),0)) + "seconds for" + fasta_idx + "\n")
            main_logfile.flush()
    return(fasta_idx)

def secondary_from_tertiary(filename):
    fasta_idx = filename.replace(".fasta","") #Get index
    secondary_structure = "" #Create variable
    pdb_filename = fasta_idx + ".pdb" #Get the pdb file
    args = ["x3dna-dssr","i="+pdb_filename] #Create the arguments for DSSR
    subprocess.call(args) #Run it
    for file in os.listdir(cwd): #Iterate over the directory
        if file.startswith("dssr"): #If the files are from dssr
            if file == "dssr-2ndstrs.dbn": #If it is that specific file
                with open("dssr-2ndstrs.dbn","r") as f: #Open it up
                    secondary_structure = f.read().splitlines()[2] #Get the dot bracket notation
            args = ["rm",file] #Remove all dssr created files anyway
            subprocess.call(args) #Call it
    with open(fasta_idx + ".secfromtert","w") as f: #Open a new kind of file
        f.write(secondary_structure) #Write the structure in
    return(secondary_structure) #Return variable

def dot_bracket_to_cns(secondary_structure,filename):
    fasta_idx = filename.replace(".fasta","") #Get index
    stack = [] #Create a stack
    counter = 1 #Create a counter
    cns_format = "" #Create a variable to add the formatting
    for i in range(len(secondary_structure)): #Begin iterating
        if secondary_structure[i] == "(": #Put on stack
            stack.append(i+1) #1 based counting instead of zero based counting
        elif secondary_structure[i] == ")": #Start popping
            pair = (stack.pop(),i+1) #Once again, 1 based counting instead of zero based counting
            #Add the required lines
            cns_format = cns_format + "{* selection for pair " + str(counter) +" base A *}" + "\n" + "{===>} base_a_" + str(counter) + "=(resid " + str(pair[0]) + " and segid B);" + "\n"
            cns_format = cns_format + "{* selection for pair " + str(counter) +" base B *}" + "\n" + "{===>} base_b_" + str(counter) + "=(resid " + str(pair[1]) + " and segid B);" + "\n"
            cns_format = cns_format + "\n"
            counter = counter + 1
    #Open the restraints file
    with open("dna-rna_restraints_" + fasta_idx + ".def","w") as f1:
        with open("dna-rna_restraints_prototype.def","r") as f2:
            lines = f2.read().splitlines() #Get the lines
            lines[210] = cns_format #Change a redundant line I placed for these ones
            text = "\n".join(lines) #Join back the lines
            f1.write(text) #Write the text to a more specific file
            f1.flush() #Flush it
    return(None) #Return

def edit_pdb_for_haddock_compliance(filename):
    fasta_idx = filename.replace(".fasta","") #Get index
    with open(fasta_idx +".pdb","r") as f:
        lines = f.read().splitlines()
    for i in range(len(lines)):
        if lines[i] != "TER":
            if "U" in lines[i][17:20]:
                lines[i] = lines[i][0:17] + "URI" + lines[i][20:]
            elif "A" in lines[i][17:20]:
                lines[i] = lines[i][0:17] + "ADE" + lines[i][20:]
            elif "C" in lines[i][17:20]:
                lines[i] = lines[i][0:17] + "CYT" + lines[i][20:]
            elif "G" in lines[i][17:20]:
                lines[i] = lines[i][0:17] + "GUA" + lines[i][20:]
        elif lines[i] == "TER":
            lines[i] = "END   "
    with open(fasta_idx + ".pdb.haddock","w") as f:
        text = "\n".join(lines)
        f.write(text)
        f.flush()
    return(None)

def change_runcns(filename):
    fasta_idx = filename.replace(".fasta","") #Get index
    with open("run_prototype.cns","r+") as f:
        lines = f.read().splitlines()
    lines[71] = lines[71].replace("protein-dna",fasta_idx+"docked")
    lines[75] = lines[75].replace("/root/haddock-deps/haddock2.2/aptamers/run1",cwd+"/"+"run"+fasta_idx)
    lines[89] = lines[89].replace("aptamer.pdb",fasta_idx + ".pdb.haddock")
    lines[91] = lines[91].replace("aptamer.psf",fasta_idx + ".psf")
    lines[95] = lines[95].replace("aptamer",fasta_idx)
    lines[154] = lines[154].replace("/root/haddock-deps/haddock2.2",haddock_dir)
    lines[158] = lines[158].replace("/root/haddock-deps/haddock2.2/aptamers/run1",cwd+"/"+"run"+fasta_idx)
    lines[1772] = lines[1772].replace("/root/haddock-deps/haddock2.2/../../cns_solve_1.3/intel-x86_64bit-linux/bin/cns",cns_exec)
    lines[1773] = lines[1773].replace("80",cores)
    with open("run" + fasta_idx + ".cns","w") as f:
        text = "\n".join(lines)
        f.write(text)
        f.flush()
    return(None)
#Now all the secondary structure stuff is done, time to reiterate over the directory to calculate the tertiary structure
def prepare_haddock(filename):
    print(filename)
    fasta_idx = filename.replace(".fasta","") #Get index
    print(fasta_idx)
    #Creating a new new.html from the prototype
    with open("new.html","w") as f1: #Open the new one to write in
        with open("new_prototype.html","r") as f2: #open the prototype to read from
            lines = f2.read().splitlines() #Get the lines
            lines.remove(lines[8]) #Remove ambiguous interactions blah blah
            lines[8] = "HADDOCK_DIR=" + haddock_dir + "<BR>" #Change to fit your own directory
            lines[10] = "PDB_FILE1=./crp_monomer.pdb<BR>" #Fit this also for your own protein
            lines[11] = "PDB_FILE2=./" + fasta_idx + ".pdb.haddock<BR>" #Set the haddock formatted DNA file
            lines[15] = "RUN_NUMBER=" + fasta_idx +"<BR>" #Run number based on index
            text = "\n".join(lines) #Join back the text
            f1.write(text) #Write it
            f1.flush()
    subprocess.call(["python2",haddock_dir+"/Haddock/RunHaddock.py"]) #First call to haddock to perform the creation of the directory
    try: #Try to remove a previous file if it so exists
        os.remove("run.cns")
    except:
        pass #Pass it if it doesn't
    os.rename("run"+fasta_idx+".cns","run.cns") #Rename for the new file
    os.remove("run"+fasta_idx+"/"+"run.cns") #Remove inner run.cns
    shutil.move("run.cns","run"+fasta_idx) #Move the outer run.cns to the inner file
    os.rename("dna-rna_restraints_"+fasta_idx+".def","dna-rna_restraints.def") #Rename the restraints
    shutil.move("dna-rna_restraints.def","run"+fasta_idx+"/data/sequence") #Move them inside
    os.chdir("run"+fasta_idx) #Change dir
    if password != "":
        args = ["sudo","-S",password,"python2",haddock_dir+"/Haddock/RunHaddock.py"]
        args = ["python2",haddock_dir+"/Haddock/RunHaddock.py"]
        subprocess.call(args) #Second call to haddock to perform the docking
    elif password == "":
        args = ["python2",haddock_dir+"/Haddock/RunHaddock.py"]
        subprocess.call(args)
    os.chrdir("structures/it1/water")
    args = ["sudo","-S",password,"python2",haddock_dir+"tools/ana_structures.csh"]
    call(args)
    with open("structures_haddock-sorted.stat","r") as f:
        lines = f.read().splitlines()
        best_struct = lines[1]
        best_struct_name,best_struct_score = best_struct.split(" ")[0:2]
    os.chdir("../../../..")
    with open("results.txt","w") as f:
        f.write(best_struct_name+"\t"+best_struct_score)
    return(None)

def clean():
    #Just clean all files by looping through the working directory
    for file in os.listdir(cwd):
        if file.endswith(".def") and file != "dna-rna_restraints_prototype.def":
            os.remove(file)
        elif file.endswith(".secfromtert"):
            os.remove(file)
        elif file.endswith(".cns") and file!= "run_prototype.cns":
            os.remove(file)
        elif file.endswith(".pdb.haddock"):
            os.remove(file)
        elif file.endswith(".html") and file != "new_prototype.html":
            os.remove(file)
        elif os.path.isdir(file):
            shutil.rmtree(file)
    return(None)

def clean_gen_one():
    filenames = list(range(1,10))
    filenames = [str(x) for x in filenames]
    for file in os.listdir(cwd):
        if file[0] in filenames:
            os.remove(file)

if __name__ == "__main__":

    #Get the current working directory
    cwd = os.getcwd()
    sys.path.append(cwd)

    #Source bashrc and bash_profile in python, just to be sure everything works
    command = shlex.split("env -i sudo bash -c 'source ~/.bashrc && ~/.bash_profile'")
    proc = subprocess.Popen(command, stdout = subprocess.PIPE)
    for line in proc.stdout:
        (key, _, value) = line.partition("=")
        os.environ[key] = value
    proc.communicate()

    #Creating a parser for you to pass the parameters in
    my_parser = argparse.ArgumentParser(description='haddock2.2 directory,\n number of cores,\n password (usually not needed),\n starting sequence (fasta file),\n,number of generations,\n,starting generation')
    #Some entry variables that need to be changed, depending on your own HADDOCK version, these are the default values right
    my_parser.add_argument('d',type=str,nargs='?',help="Absolute path to HADDOCK 2.2 directory",default = "/root/haddock-deps/haddock2.2")
    my_parser.add_argument('c',type=str,nargs='?',help="Number of cores to be used by multiprocessing (default is 96)",default = "96")
    my_parser.add_argument('p',type=str,nargs='?',help="Password for admin access, unneeded",default ="oneshot")
    my_parser.add_argument('f',type=str,nargs='?',help="The first file to start the program",default ="0.fasta")
    my_parser.add_argument('g',type=str,nargs='?',help="The number of generation that the program should run for, time per generation depends heavily on number of cores",default = "10")

    #Read args in and assign them
    args = my_parser.parse_args()
    cores = args.c
    haddock_dir = args.d
    password = args.p #Insert your own PC's password here, if it has one, leave it blank if it does not
    firstfile = args.f
    generations = args.g

    #Get the sequence length for the aptamer you will be developing
    with open(firstfile,"r") as f:
        global sequence_length
        sequence_length = len(f.read().splitlines()[1])

    cns_exec = haddock_dir + "/../../cns_solve_1.3/intel-x86_64bit-linux/bin/cns" #CNS executable location

    print("Starting")

    num_threads = 10 #Ten sequences per generation
    #Setting up gen one
    firstfile_idx = firstfile.replace(".fasta","")
    with open(firstfile,"r") as f: #Open up the original file
        first_seq = f.read().splitlines()[1] #Obtain sequence
    (ss,mfe) = RNA.fold(first_seq) #Fold it
    with open(firstfile_idx+".secstr,"w") as f: #Write secondary structure file
        f.write(">" + firstfile_idx + " " + str(mfe)) #Right energy
        f.write("\n")
        f.write(ss) #Write sequence
    for i in range(9): #Create 9 offspring from the first file
        max_index = get_max_index() #Get the max index each time, just to be sure that the creation is going fine
        mutate_seq_and_get_secondary_structure(firstfile,max_index) #Create .fasta and .secstr files for them
    filenames = list(range(int(firstfile_idx_temp),int(firstfile_idx_temp)+10)) #Get the filenames from the first generation (those are set)
    filenames = [str(x) + ".fasta" for x in filenames] #Get the actual fasta name (not that it really matters)
    with Pool(num_threads) as pool: #Thread pool 1
        pool.map(rna_tertiary_structure_prediction,filenames) #Predict tertiary structure
    with Pool(num_threads) as pool: #Thread pool 2 (in order to synchronise the two)
        pool.map(rna_tertiary_structure_refinement,filenames) #Refine tertiary structure
    secondary_structures = list(map(secondary_from_tertiary,filenames)) #This takes too little to need pooling, get secondary structure from tertiary
    list(map(dot_bracket_to_cns,secondary_structures,filenames)) #Create ten separate rna-dna_restraints.def files, one for each
    list(map(change_runcns,filenames)) #Create ten separate run.cns files, one for each
    list(map(edit_pdb_for_haddock_compliance,filenames)) #Edit all filenames to make sure they are HADDOCK compliant
    for candidate in filenames:
        with ProcessPoolExecutor(int(cores)) as executor:
            future = executor.submit(prepare_haddock,candidate)
