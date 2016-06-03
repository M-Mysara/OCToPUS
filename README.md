# OCToPUS
##Amplicon sequencing processing pipeline
##From Reads to Operational Taxonomic Units
The development of high-throughput sequencing technologies has provided researchers with an efficient approach to assess the microbial diversity at an unseen depth, particularly with the recent advances in the Illumina MiSeq sequencing platform. However, analysing such high-throughput data is posing important computational challenges, requiring specialized bioinformatics solutions at different stages during the processing pipeline, such as assembly of paired-end reads, chimera removal, correction of sequencing errors and clustering of those sequences into Operational Taxonomic Units (OTUs).
Here we introduce OCToPUS, which is making an optimal combination of different algorithms. OCToPUS achieves the lowest error rate, minimum number of spurious OTUs, and the closest correspondence to the existing community, while retaining the uppermost amount of reads when compared to other pipelines. 

OCToPUS software can be downloaded from the release section here (https://github.com/M-Mysara/OCToPUS/releases) 

# Tutorial Video:
You can download a tutorial video illustrating running OCToPUS using the supplied test dataset from this link:

    https://github.com/M-Mysara/OCToPUS/releases/download/OCToPUS/OCToPUS_Tutorial.mp4
    
# Installation Requirement
Both Perl and Java needed to be installed to run OCToPUS. All other software packages that are required to run OCToPUS are included in the downloaded file (OCToPUS_V?.run). In case you are interested in the source code of OCToPUS, this is also included in the downloaded file. Only in case you want to run the source code, you will need to install those software components separately, and adapt the source code referring to those software components accordingly. In all other cases, we encourage the end-user to use the OCToPUS_V?.run executable.

# Included Software
Software listed below is used by the IPED algorithm. However you do NOT need to install it separately as these software modules are included in the IPED software.

    Mothur v.1.33.3:
         Available at http://www.mothur.org/wiki/Download_mothur. 
         Note about changes made in the mothur package integrated in this package:
         The command called "pre.cluster" is modified to be compatible with the IPED algorithm.
         The command called "make.contigs" is modified to produce an additional IPED-formatted quality file.
    WEKA 3.7.11: 
         Available online at http://www.cs.waikato.ac.nz/ml/weka/.
    SPAdes 3.5.0:   
         Available at http://spades.bioinf.spbau.ru/
    IPED v.1
         Available online at https://github.com/M-Mysara/IPED/
         Note about changes made in IPED to remove redundant steps and increase the compatabilities   
    CATCh v.1
         Available online at  http://science.sckcen.be/en/Institutes/EHS/MCB/MIC/Bioinformatics/CATCh
         Note about changes made in CATCh to remove redundant steps and increase the compatabilities
         
All of these software (in addition to OCToPUS) are under the GNU licence.

In addition due to license restrictions, usearch has to be downloaded and installed by the user. It will be parsed to the OCToPUS via _u option (see below)

      usearch 8.1.1861
       Available at http://www.drive5.com/usearch/

# Syntax:

    !!! Make sure you use an underscore "_" (and not a hyphen "-") to specify the option you want to set.
    
    !!! Make sure to use the complete PATH when describing files (i.e. "/YOUR/COMPLETE/PATH/" instead of "./" )

Mandatory Options:
	
        _f stability file (tab separated file with sample ID, forward fastq, reverse fastq files)  
           for example: 
                      Sample1 Sample1_L001_R1_001.fastq Sample1_L001_R2_001.fastq
                      Sample2 Sample2_L001_R1_001.fastq Sample2_L001_R2_001.fastq
                      
        _r Reference database for aligning as silva (mothur compatable). 
            can be downloaded from: http://www.mothur.org/wiki/Silva_reference_files
            
        _o Output directory 
           for example: /YOUR/OUTPUT/PATH/
           
        _u USEARCH executable path  
        _i Output folder name (default: random number)
	 
	 #Non-mandatory Options:
	_p number of processors (default =1)
