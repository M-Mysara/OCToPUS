# OCToPUS
## Amplicon sequencing processing pipeline
### Mysara, M., Njima, M., et al., 2017. From reads to operational taxonomic units: an ensemble processing pipeline for MiSeq amplicon sequencing data. GigaScience.
##From Reads to Operational Taxonomic Units
The development of high-throughput sequencing technologies has provided researchers with an efficient approach to assess the microbial diversity at an unseen depth, particularly with the recent advances in the Illumina MiSeq sequencing platform. However, analysing such high-throughput data is posing important computational challenges, requiring specialized bioinformatics solutions at different stages during the processing pipeline, such as assembly of paired-end reads, chimera removal, correction of sequencing errors and clustering of those sequences into Operational Taxonomic Units (OTUs).
Here we introduce OCToPUS, which is making an optimal combination of different algorithms. OCToPUS achieves the lowest error rate, minimum number of spurious OTUs, and the closest correspondence to the existing community, while retaining the uppermost amount of reads when compared to other pipelines. 

OCToPUS software can be downloaded from the release section here (https://github.com/M-Mysara/OCToPUS/releases) 

# Installation Requirement
Both Perl and Java needed to be installed to run OCToPUS. All other software packages that are required to run OCToPUS are included in the downloaded file (OCToPUS_V?.run). In case you are interested in the source code of OCToPUS, this is also included in the downloaded file. Only in case you want to run the source code, you will need to install those software components separately, and adapt the source code referring to those software components accordingly. In all other cases, we encourage the end-user to use the OCToPUS_V?.run executable.

# Included Software
Software listed below is used by the OCToPUS algorithm. However you do NOT need to install it separately as these software modules are included in the OCToPUS software.

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
         it can be downloaded from: http://www.mothur.org/wiki/Silva_reference_files
            
    _o Output directory 
         for example: /YOUR/OUTPUT/PATH/
           
    _u USEARCH executable path  
         downlaoded from http://www.drive5.com/usearch/ (tested on version 8.1.1861) 
	 for example (_u /home/username/usearch8.1.186linux32
         
    _i ID of your output folder name (default: random number)

         
Non-mandatory Options:

    _p number of processors (default =1)
    
# Output Files
The OCToPUS program generates different text output files within the output directory named with random number or the specified name in _i option.
The final files are:

    OCToPUS_OTUs.fasta: fasta file with the OTUs sequences.
    OCToPUS.shared: shared file with the OTU table, it can be exported to mothur pipeline for downstream analysis.
    OCToPUS.biom: biom file with OTU table, it can be exported to QIIME pipeline for downstream analysis.
    OCToPUS_otutab_txt: OTU table, it can be exported to USEARCH pipeline for downstream analysis.

The temporaty files are:
the following is performed for each sample within the stability files and named accordingly

    For SPAdes: it is stored in "correct" folder, containing both forward and reverse fastq files after Pre-assembly error correction. The files overwrite the former sample's SPAdes output 
    For mothur: the intermediate files exist within the output directory after:
    	assembly via make.contgis (.contigs.qual and .trim.contigs.fasta files)
    	quality filtering via trim.seqs (.trim.fasta)
    	dereplication via unique.seqs (.unique.fasta and .names files)
    	alignment via align.seqs (.align)
    	alignment screening via screen.seqs (.good.align and .good.names files)
    	aligmnent filtering via filter.seqs (.filter.fasta)
    	final dereplication via unique.seqs (.unqiue.fasta and .names files)
    For IPED: the denoised fasta and name file are storred (under ./IPED_Final/SampleID/) as Results.IPED.names & Results.IPED.fasta
 
 the following is performed after all samples are joined together:

    For CATCh: The chimera detection of the different tools are stored within the output directory:
    	For Perseus: via mothur command chimera.perseus (as .perseus.chimeras)
    	For ChimeraSlayer: via mothur command chimera.slayer (as .slayer.chimeras)
    	For Uchime: via mothur command chimera.uchime (as .uchime.chimeras)
    	CATCh finaly output is stored under "All" folder" as CATCH_Results.arff.Final_Results.

    For UPARSE, the intermediate files exist within the output directory after 
    	sorting as sorted.fasta
    	clustering as otus.fasta
    	mapping as mapping.fasta
    
	  	
# Testing
	./OCTOPUS.run _f /YOUR_PATH/stability.files _o /YOUR_OUTPUT_PATH//Out/ _r /YOUR_PATH/silva.bacteria.fasta _p 10 _u /YOUR_PATH/usearch8.1.1861_i86linux32 _i test


# Citing:
If you are going to use OCToPUS, please cite it with the included software (mothur, WEKA, iped, catch, spades) together with usearch:

    OCToPus:	Mysara, M., Njima, M., et al., 2017. From reads to operational taxonomic units: an ensemble processing pipeline for MiSeq amplicon sequencing data. GigaScience.
    IPED:	Mysara M, Leys N, Raes J, Monsieurs P. (2016). IPED: a highly efficient denoising tool for Illumina MiSeq Paired-end 16S rRNA gene amplicon sequencing data. BMC Bioinformatics 17:192.
    CATCh:	Mysara M, Saeys Y, Leys N, Raes J, Monsieurs P. (2015). CATCh, an ensemble classifier for chimera detection in 16S rRNA sequencing studies. Appl. Environ. Microbiol. 81:1573–84.
    mothur:	Schloss PD, Westcott SL, Ryabin T, Hall JR, Hartmann M, Hollister EB, et al. (2009). Introducing mothur: open-source, platform-independent, community-supported software for describing and comparing microbial communities. Applied and environmental microbiology 75:7537–41.
    WEKA:	Hall M, National H, Frank E, Holmes G, Pfahringer B, Reutemann P, et al. (2009). The WEKA Data Mining Software?: An Update. SIGKDD Explorations 11:10–18.
    SPAdes:	Bankevich A, Nurk S, Antipov D, Gurevich AA, Dvorkin M, Kulikov AS, et al. (2012). SPAdes: a new genome assembly algorithm and its applications to single-cell sequencing. J. Comput. Biol. 19:455–77.
    UPARSE:	Edgar RC. (2013). UPARSE: highly accurate OTU sequences from microbial amplicon reads. Nat. Methods 10:996–8.

Contact:
For questions, bugs and suggestions, please refer to mohamed.mysara@gmail.com & pieter.monsieurs@sckcen.be
Developed by M.Mysara et al. 2016
