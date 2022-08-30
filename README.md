# cirsium-2022
Contains a description of the methods and various code from "[Paralogy or reality? Exploring gene assembly errors in a target enrichment dataset.](https://github.com/rosenam/cirsium-2022/blob/main/rosen_manuscript.pdf)"

## Prerequisites
[HybPiper v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki) and all associated dependencies.

## Pipeline

### Quality assessment of raw reads
Raw reads (.fastq files) were given an initial assessment using [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). Initial quality control meausures should be taken according to these results. 

### Raw read trimming
Adapter content and low quality reads were trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and the following options:
ILLUMINACLIP:[path_to]/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36

### Gene assembly
Genes from Hyb-Seq data were assembled using [HybSeq v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki), though there is now a newer release ([HybPiper v.2.0](https://github.com/mossmatters/HybPiper)) available.

The original target file can be found [here]:

### Multiple Sequence Alignment (MSA)


