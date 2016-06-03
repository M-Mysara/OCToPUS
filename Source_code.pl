#! /usr/local/bin/perl
#.....................License.................................
#	 OCTOPUS: Optimized CATCh, mothur, IPED, UPARSE and SPADE 
#    Copyright (C) 2016  <M.Mysara et al>

#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
	
#......................Packages Used..........................
use strict;
use Getopt::Std;
use File::Basename;
#####################
#Initializing the options
my %opts;
getopt('fropui',\%opts);
my @options=('f','r','o','p','u','i'); 
#Assigning the options [with "_" instead of "-" that contradict with compression tool used"
foreach my $value(@options){
	for(my $a=0;$a<32;$a=$a+2){
		my $temp_Value = '_'.$value;
		if($temp_Value eq $ARGV[$a]){$opts{$value}=$ARGV[$a+1];}
	}
}
#Initialize global variables
my $output="";
my $reference="";
my $processors=1;
my $u="";
my $logfile;
if (-e $opts{f}){open FH,$opts{f};}else{print "Please insert a valid stability file\n";}
if (-e $opts{r}){$reference=$opts{r};}else{print "Please insert a valid reference alignemnt file\n";}
if (!$opts{o}){print "Please assign output directory\n";exit;}else{$output=$opts{o};}
if (!$opts{p}){print "Using one processor\n";}else{$processors=$opts{p};}
if (-e $opts{u}){print "Using USEARCH version supplied\n";$u=$opts{u};}else{print "Please insert a working USEARCH  executable\n";exit;}
if(!defined($opts{i})){$logfile=int(rand(1000000000000000));}else{$logfile=$opts{i};}
###creating output directory in the provided path
$output=$output."/".$logfile."/";
mkdir($output);
if(-e $opts{f} && -e $opts{r}){
my $command1="cat ";
my $command2="cat ";
my $command3="cat ";
my @groups;										
foreach my $line(<FH>){
	#Initialize variables
	my $forward="";
	my $reverse="";
	my $sample="";
	my $log=$sample.".logfile";
	my @array=split("\t",$line);
	chomp($array[2]);
	if(!$array[0]){print"Please add a valid group name in $line\n";exit;}else{$sample=$array[0];}
	if(-e $array[1]){$forward=$array[1];}else{print"Please check if the forward file is properly added in $line\n";exit;}
	if(-e $array[2]){$reverse=$array[2];}else{print"Please check if the reverse file is properly added in $line\n";exit;}
	#Running Bay-Hammer to remove errors perior assembly
	print "Running SPADE for $sample...\n";
	system "./SPAdes\-3\.5\.0\-Linux/bin/spades.py --only-error-correction -1 $forward -2 $reverse -o $output > $log 2>&1 >>$log";
	
	$forward = basename($forward);$forward=$output."/corrected/".$forward; $forward=~s/\.fastq/.00.0_0.cor.fastq.gz/;
	$reverse = basename($reverse);$reverse=$output."/corrected/".$reverse; $reverse=~s/\.fastq/.00.0_0.cor.fastq.gz/;
	system("gunzip $forward");system("gunzip $reverse");#use gzip -d instead
	$forward=~s/\.gz//;	$reverse=~s/\.gz//;
	my $contig=$forward;$contig=~s/fastq/trim.contigs.fasta/;$contig=~s/\/corrected//;
	my $qual=$forward;$qual=~s/fastq/contigs.qual/;$qual=~s/\/corrected//;
	#Running mothur using automated pipeline (please adjust the parameters as you prefer)
	print "Running mothur for $sample...\n";
	system "./mothur \"\#set.dir(output=$output);set.logfile(name=$sample.logfile,append=T);make.contigs(ffastq=$forward,rfastq=$reverse,processors=$processors);trim.seqs(fasta=current, maxambig=0, maxhomop=8, minlength=200);unique.seqs(fasta=current);align.seqs(fasta=current, reference=$reference, flip=T);screen.seqs(fasta=current, name=current, optimize=start-end-length, criteria=95);filter.seqs(fasta=current, vertical=T);unique.seqs(fasta=current, name=current);list.seqs(name=current)\"> log";

	my $fasta=$forward;$fasta=~s/.fastq/.trim.contigs.trim.unique.good.filter.unique.fasta/;$fasta=~s/\/corrected//;
	my $name=$forward;$name=~s/.fastq/.trim.contigs.trim.unique.good.filter.names/;$name=~s/\/corrected//;
	my $list=$forward;$list=~s/.fastq/.trim.contigs.trim.unique.good.filter.accnos/;$list=~s/\/corrected//;

	#Running IPED
	print "Running IPED for $sample...\n";
	system "perl ./IPED_main.pl _n $name _f $fasta _c $contig _q $qual _p $processors _o $output _i $sample >>$log";

	my $fasta=$output."/IPED_Final/".$sample."/Results.IPED.fasta";
	my $name=$output."/IPED_Final/".$sample."/Results.IPED.names";
	my $group=$output."/IPED_Final/".$sample."/Results.IPED.groups";
	system("perl -pe \"s/^\([\\w\\W]+\)\\n/\\\$1\\t$sample\\n/g\" $list > $group");
	$command1=$command1."$fasta ";
	$command2=$command2."$name ";
	$command3=$command3."$group ";
	push(@groups,$sample);
}
my $log=$output."/OCTOPUS.logfile";
#merging the fasta, name, group files together
my $fasta=$output."/All.fasta";
my $name=$output."/All.names";
my $group=$output."/All.group";
$command1=$command1."> ".$output."/All.fasta";system $command1;
$command2=$command2."> ".$output."/All.names";system $command2;
$command3=$command3."> ".$output."/All.group";system $command3;
print "Running CATCh for all samples...\n";	
#Running chimera checking algorithms
system "./mothur \"\#set.dir(output=$output);set.logfile(name=$log,append=T);unique.seqs(fasta=$fasta,name=$name);chimera.uchime(fasta=current,name=current,group=$group,processors=$processors);chimera.slayer(fasta=current,name=current,group=current,processors=$processors);chimera.perseus(fasta=current,name=current,group=current,processors=$processors)\" > $log 2>&1";
	
my $uchime=$output."/All.unique.uchime.chimeras";
my $slayer=$output."/All.unique.slayer.chimeras";
my $perseus=$output."/All.unique.perseus.chimeras";

#Running CATCh
system "perl CATCh.pl _f $fasta _n $name _h $output _i All _m d _p $processors _y $slayer _z $perseus _x $uchime >>$log";	
	
my $accnos=$output."/All/Tools_Results/CATCH_Result.arff.Final_Result";
system"echo \"CATCh_Chimera_Check\" >accnos";
system "grep -P \"\tChimeric\" $accnos | cut -f1 >> accnos";
system "./mothur \"\#set.dir(output=$output);set.logfile(name=$log,append=T);remove.seqs(fasta=$fasta,name=$name,group=$group,accnos=accnos);split.groups(fasta=current,name=current,group=current)\" >> $log";

#coverting to UPARSE format
my $command="cat ";
foreach my $sample(@groups){
	my $fasta=$output."/All.pick.".$sample.".fasta";
	my $name=$output."/All.pick.".$sample.".names";
	system "./mothur \"\#set.dir(output=$output);set.logfile(name=$log,append=T);sort.seqs(fasta=$fasta,name=$name)\" >> $log";
	my $fasta=$output."/All.pick.".$sample.".sorted.fasta";
	my $name=$output."/All.pick.".$sample.".sorted.names";
	my $fasta_uparse=$output."/All.pick.".$sample.".uparse.fasta";
	system "perl mothur2uparse.pl $fasta $name a $sample > $fasta_uparse";
	$command=$command."$fasta_uparse ";
}
my $fasta_uparse=$output."/All.uparse.fasta";
system $command." > $fasta_uparse";
#Running UPARSE

print "Running UPARSE for all samples...\n";	
my $fasta_uparse_sort=$fasta_uparse;
$fasta_uparse_sort=~s/uparse/uparse_sorted/;
system "$u -sortbysize $fasta_uparse -fastaout $fasta_uparse_sort -minsize 2 >>$log 2>&1";
my $fasta_uparse_sort_otus=$fasta_uparse_sort;
$fasta_uparse_sort_otus=~s/sorted/sorted_otus/;
system "$u -cluster_otus $fasta_uparse_sort -otus $fasta_uparse_sort_otus -relabel Otu >>$log 2>&1";
my $mothur_shared=$output."/OCTOPUS.shared";
my $otutab_biom=$output."/OCTOPUS.biom";
my $map_uc=$output."/All.uparse.mapping";
my $otutab_txt=$output."/OCTOPUS.otutab_txt";
system("$u -usearch_global $fasta_uparse_sort -db $fasta_uparse_sort_otus -strand plus -id 0.97 -mothur_shared_out $mothur_shared -otutabout $otutab_txt -biomout $otutab_biom -uc $map_uc >>$log 2>&1");
system("perl -pe \"s/usearch/0.03/g\" -i $mothur_shared");
system("cp $fasta_uparse_sort_otus $output\/OCTOPUS_OTUs.fasta");


}
else{

	usage();
}
sub usage{
print
"	
	||||||||||||||||||||||||||||||||||||||||||||||||
	||              Welcome To OCTOPUS	      ||
	|| Pipeline for 16s metagenomics analysis   ||
	||	for more accurate OTU clustering      ||
	||    Copyright (C) 2015  <M.Mysara et al>    ||
	||||||||||||||||||||||||||||||||||||||||||||||||

 OCTOPUS version 1, Copyright (C) 2016, M.Mysara et al
 OCTOPUS comes with ABSOLUTELY NO WARRANTY.
 This is free software, and you are welcome to redistribute it under
 certain conditions; please refer to \'COPYING\' for details.;

 The software also includes \"mothur\",\"SPADE\",\"WEKA\",\"IPED\",\"CATCh\"   also under GNU Copyright
 
 
Command Syntax:
OCTOPUS.run {options} 	

#Always use complete PATH when describing files [reference or fastq files]
#mothur version included has been modified to be IPED compatable
#CATCh version included has been modified to be OCTOPUS compatable
#Perl, Java, gunzip need to be pre-installed on your shell


	#Mandatory Options:
	 _f stability file (tab separated file with sample ID, forward fastq, reverse fastq files  
	 _r Reference database for aligning as silva. 
	 _o Output directory [e.g. /YOUR/OUTPUT/PATH/]
	 _u USEARCH executable path  
	 _i Output folder name (default: random number)
	 
	 #Non-mandatory Options:
	_p number of processors (default =1)

 For Queries about the installaion, kindly refer to \'README.txt\'
 For Queries about the Copy rights, kindly refer to \'COPYING.txt\'


CITING OCTOPUS (Mysara et al, 2016) 
please cite the included software (Mothur, UPARSE, SPADE, CATCH, IPED, WEKA)]:
PD.Schloss et al. 2009, Edgar 2013 ,Nurk et al. 2013, M.Mysara et al. 2015, M.Mysara et al. 2016, M. Hall et al. 2009, respectively

";
}
