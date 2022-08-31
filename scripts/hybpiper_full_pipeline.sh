#!/usr/bin/env bash
#SBATCH --job-name=hybpiper_full_pipeline
#SBATCH --nodes=1
#SBATCH --ntasks=4    # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --partition=shas
#SBATCH --qos=long   # modify this to reflect which queue you want to use.
#SBATCH --time=168:00:00   # modify this to reflect how long to let the job go. 
#SBATCH --output=log_hybpiper_full_pipeline_%j.txt

# Gene assembly, intron extraction and subsequent file clean-up. Iterates through each specimen in namelist.txt in a consecutive manner.

while read name
do

python reads_first.py --bwa -b /projects/cirsium/01_input/target_file.fasta --prefix $name -r /projects/cirsium/01_input/trimmed/$name\_*_paired.fastq.gz

python intronerate.py --prefix $name 

python cleanup.py $name

done < /projects/cirsium/01_input/namelist.txt

# Gather overall assembly statistics. hybpiper_stats.py produces summary statistics using gene_lengths.txt, but this text file can also be used to produce a gene recovery heatmap using R (gene_recovery_heatmap.R can be found in the HybPiper documentation)

python get_seq_lengths.py /projects/cirsium/01_input/target_file.fasta /projects/cirsium/01_input/namelist.txt dna > ./stats/gene_lengths.txt

python hybpiper_stats.py ./stats/gene_lengths.txt /projects/cirsium/01_input/namelist.txt > ./stats/test_stats.txt

# Compile paralog warnings for each specimen into a single text file for later use

while read name
do
echo $name
python paralog_investigator.py $name
done < /projects/cirsium/01_input/namelist.txt

