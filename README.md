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
Adapter content and low quality reads were trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and the following options:

```
ILLUMINACLIP:<path_to>/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36
```

This is the script I used to trim each file consecutively: [trimmer.sh](https://github.com/rosenam/cirsium-2022/blob/main/scripts/trimmer.sh)

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
