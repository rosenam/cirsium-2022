#!/usr/bin/env bash	 
#SBATCH --job-name=trim
#SBATCH --nodes=1
#SBATCH --ntasks=4 # modify this number to reflect how many cores you want to use (up to 24 per node) 
#SBATCH --partition=shas
#SBATCH --qos=long
#SBATCH --time=168:00:00   # modify this to reflect how long to let the job go. 
#SBATCH --output=trimmer_log_%j.txt


module load jdk                 #load java module

for fileR1 in *R1.fastq.gz       #run trimmomatic for each pair of files
do
fileR2=`echo ${fileR1} | sed 's/R1/R2/'`                                  #name fileR2 by swapping R1 with R2
fwdpair=`echo ${fileR1} | sed 's/R1.fastq.gz/fwd_paired.fastq/'`          #give each file a more informative name
revpair=`echo ${fileR2} | sed 's/R2.fastq.gz/rev_paired.fastq/'`
fwdunp=`echo ${fileR1} | sed 's/R1.fastq.gz/fwd_unpaired.fastq/'`
revunp=`echo ${fileR2} | sed 's/R2.fastq.gz/rev_unpaired.fastq/'`

#run trimmomatic with the correct adapter file and trimming options of your choice
java -jar trimmomatic-0.39.jar PE $fileR1 $fileR2 $fwdpair $fwdunp $revpair $revunp ILLUMINACLIP:/projects/cirsium/01_input/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36
done

mkdir ../trimmed
mv *paired.fastq ../trimmed
