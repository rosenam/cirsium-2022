# cirsium-2022
Contains a description of the methods and various code from "[Paralogy or reality? Exploring gene assembly errors in a target enrichment dataset.](https://github.com/rosenam/cirsium-2022/blob/main/rosen_manuscript.pdf)"

## Prerequisites
[HybPiper v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki) and all associated dependencies.

## Pipeline

### Project setup
Create three directories: 01_input, 02_scripts, and 03_ouput

Create a new conda environment for the project: conda create --name mycustomenv

### Quality assessment of raw reads
Raw reads (.fastq files) were given an initial assessment using [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). Initial quality control meausures should be taken according to these results. 

### Raw read trimming
Adapter content and low quality reads were trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and the following options:
ILLUMINACLIP:[path_to]/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36

### Gene assembly and sequence extraction
Genes from Hyb-Seq data were assembled using [HybSeq v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki), though there is now a newer release ([HybPiper v.2.0](https://github.com/mossmatters/HybPiper)) available.

HybPiper requires two inputs: the trimmed fastq files and a target file that contains the complete sequences (targets) to be recovered. The original target file used in the manuscript can be found [here](https://github.com/Smithsonian/Compositae-COS-workflow/blob/master/COS_sunf_lett_saff_all.fasta):
However, the sequence names had to be rearranged to work appopriately with HybPiper, which was done using this simple script: 
The target file with correctly arranged sequence names can be found [here].
For more information about the required format of the targt file, see [HybPiper.](https://github.com/mossmatters/HybPiper)

--------

After assembly, we should clean up the output, gather some statistics, and extract the assembled sequences. The user can extract the exon sequences, intron sequences, or supercontigs containing both exons and introns. 

```

```

### Multiple Sequence Alignment (MSA)


