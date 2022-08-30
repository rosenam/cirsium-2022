# cirsium-2022
Contains the code from "Paralogy or reality? Exploring gene assembly errors in a target enrichment dataset."

## Prerequisites
[HybPiper v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki) and all associated dependencies

## Pipeline

### Quality Assessment of Raw Reads
Raw reads are first assessed using [FASTQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). Initial quality control meausures should be taken according to these results. 

### Raw read trimming
Adapter content and low quality reads are trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and options:

ILLUMINACLIP:[path_to]/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36


