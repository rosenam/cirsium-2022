# cirsium-2022
Contains a description of the methods and various code from the manuscript "[Paralogy or reality? Exploring gene assembly errors in a target enrichment dataset.](https://github.com/rosenam/cirsium-2022/blob/main/rosen_manuscript.pdf)"

## Prerequisites
[HybPiper v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki) and all associated dependencies.

## Pipeline

### Project setup
Create three directories: 01_input, 02_scripts, and 03_ouput

Create a new conda environment for the project: conda create --name mycustomenv

### Quality assessment of raw reads
Raw reads (.fastq files) were given an initial assessment using [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). Initial quality control meausures should be taken according to these results. 

### Raw read trimming
Adapter content and low quality reads were trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and options set to:
* remove leading low quality or N bases with a Phred-scaled quality score below 20
* remove trailing low quality bases below quality 20
* scan the read with a 5-bp sliding window, cutting when the average quality within each window drops below 20
* exclude reads less than 36 bases long

Example code:

```
java -jar trimmomatic-0.39.jar PE $fileR1 $fileR2 $fileR1.pair.fastq $fileR1.unp.fastq $fileR2.pair.fastq $fileR2.unp.fastq ILLUMINACLIP:/projects/cirsium/01_input/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36
```

This is the script I used to trim each file consecutively and place all trimmed reads into a single directory: [trimmer.sh](https://github.com/rosenam/cirsium-2022/blob/main/scripts/trimmer.sh)

### Gene assembly and sequence extraction
Genes from Hyb-Seq data were assembled using [HybSeq v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki), though there is now a newer release ([HybPiper v.2.0](https://github.com/mossmatters/HybPiper)) available.

HybPiper requires trimmed fastq files, a target file that contains the complete sequences (targets) to be recovered, and a name list for the specimens. The original target file used in the manuscript can be found [here](https://github.com/Smithsonian/Compositae-COS-workflow/blob/master/COS_sunf_lett_saff_all.fasta):
However, the sequence names had to be rearranged to work appopriately with HybPiper, which was done using this simple Python script: 
The target file with correctly arranged sequence names can be found [here].
For more information, see [HybPiper.](https://github.com/mossmatters/HybPiper)

--------

After assembly, run the HybPiper function intronerate.py to create assemblies for the supercontig (gene sequence containing exons and introns) and introns. This step can be skipped if introns are not of interest. 

Finally, clean up the output, gather statistics on the assemblies, compile paralog warnings, and extract the assembled sequences. The user can extract the exon sequences, intron sequences, or supercontigs containing both exons and introns. 

--------

This is the script I used to tie together all of these HybPiper functions: [full_pipeline.sh]

If all trimmed reads are placed in a single directory, this script will perform gene assembly and clean up for each specimen consecutively, and then extract sequence data, paralog warnings, and assembly statistics for all specimens.

### Sequence alignment and quality control
#### Alignment
Sequences were aligned using [MAFFT v.7.48](https://mafft.cbrc.jp/alignment/software/) and the options: --preservecase --localpair --maxiterate 1000 

Example code:

```
mafft --preservecase --localpair --maxiterate 1000 $gene > $gene.aligned.fasta
```

--------
#### Alignment trimming
Step 1: Perform heads-or-tails alignment
Step 2: Use trimAl v.1.4 to 
* discard inconsistent alignment positions between heads-and-tails alignments
* discard alignment positions that contain gaps in greater than 90% of the sequences
* discard hypervariable alignment positions based on a nucleotide-similarity threshold of 0.001
* discard entire sequences when less than 50% of their nucleotide characters have an overlap score of 0.5

Example code:
```
trimal -compareset fileset.txt -out gene.trim_al.fasta -ct 0.5 -gt 0.1 -st 0.001 -resoverlap 0.5 -seqoverlap 0.5

```
--------
#### Outlier removal
[TAPER v.0.1.6](https://github.com/chaoszhang/TAPER) was used to mask regions of individual sequences that were 
divergent outliers in comparison to the rest of the sequences in the alignment.

Example code:
```
correction_multi.jl gene.trim_al.fasta > gene_taper.fasta -c 1 -m N
```
--------
#### Paralog removal
Paralogs have the potential to confound phylogenetic analyses, so to be cautious, all genes flagged by HybPiper as containing potential paralogs are removed from the dataset.

