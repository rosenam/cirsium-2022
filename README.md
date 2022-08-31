# cirsium-2022
Contains a description of the methods and various code from the manuscript "[Paralogy or reality? Exploring gene assembly errors in a target enrichment dataset.](https://github.com/rosenam/cirsium-2022/blob/main/rosen_manuscript.pdf)"

### Prerequisites
[FASTQC v.0.11.9](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)  
[Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic)  
[HybPiper v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki) and all associated dependencies  
[MAFFT v.7.48](https://mafft.cbrc.jp/alignment/software/)  
[trimAl v.1.4](https://github.com/inab/trimal)  
[TAPER v.0.1.6](https://github.com/chaoszhang/TAPER)  
[AMAS v.1.0](https://github.com/marekborowiec/AMAS)  
[IQTREE v.2.1.3](https://github.com/Cibiv/IQ-TREE)  
[TNT v.1.5](http://www.lillo.org.ar/phylogeny/tnt/)  
[ASTRAL v.5.7.8](https://github.com/smirarab/ASTRAL)  

# Pipeline

## Quality assessment of raw reads
Raw reads (.fastq files) were given an initial assessment using [FASTQC v.0.11.9](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). Initial quality control measures should be taken according to these results. 

## Raw read trimming
Adapter content and low quality reads were trimmed using [Trimmomatic v.0.39](http://www.usadellab.org/cms/?page=trimmomatic) for paired-end reads and options set to:
* remove leading low quality or N bases with a Phred-scaled quality score below 20
* remove trailing low quality bases below quality 20
* scan the read with a 5-bp sliding window, cutting when the average quality within each window drops below 20
* exclude reads less than 36 bases long

Example code:

```
java -jar trimmomatic-0.39.jar PE fileR1 fileR2 fileR1.pair.fastq fileR1.unp.fastq fileR2.pair.fastq fileR2.unp.fastq ILLUMINACLIP:/projects/cirsium/01_input/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20 MINLEN:36
```

This is the script I used to trim each file consecutively and place all trimmed reads into a single directory: [trimmer.sh](https://github.com/rosenam/cirsium-2022/blob/main/scripts/trimmer.sh)

## Gene assembly and sequence extraction
Genes from Hyb-Seq data were assembled using [HybSeq v.1.3](https://github.com/mossmatters/HybPiper/wiki/HybPiper-Legacy-Wiki), though there is now a newer release ([HybPiper v.2.0](https://github.com/mossmatters/HybPiper)) available.

HybPiper requires trimmed fastq files, a target file that contains the complete sequences (targets) to be recovered, and a name list for the specimens. The original target file used in the manuscript can be found [here](https://github.com/Smithsonian/Compositae-COS-workflow/blob/master/COS_sunf_lett_saff_all.fasta).

However, the sequence names had to be rearranged to work appopriately with HybPiper, which was done using this simple Python script: 

The target file with correctly arranged sequence names can be found [here](https://github.com/rosenam/cirsium-2022/blob/main/COS_sunf_lett_saff_all.fasta).

For more information, see [HybPiper.](https://github.com/mossmatters/HybPiper)

--------

After assembly, the HybPiper function intronerate.py was run to create assemblies for the supercontig (gene sequence containing exons and introns) and introns. This step can be skipped if introns are not of interest. 

Finally, I cleaned up the output files, gathered statistics on the assemblies, compiled paralog warnings, and extracted the assembled sequences. The user can extract the exon sequences, intron sequences, or supercontigs containing both exons and introns. 

--------

This is the script I used to tie together all of these HybPiper functions: [hybpiper_full_pipeline.sh](https://github.com/rosenam/cirsium-2022/blob/main/scripts/hybpiper_full_pipeline.sh).

If all trimmed reads are placed in a single directory, this script will perform gene assembly and clean up for each specimen consecutively, and then extract sequence data, paralog warnings, and assembly statistics for all specimens.

## Sequence alignment and quality control
### Alignment
Sequences were aligned using [MAFFT v.7.48](https://mafft.cbrc.jp/alignment/software/) and the options: --preservecase --localpair --maxiterate 1000 

Example code:

```
mafft --preservecase --localpair --maxiterate 1000 $gene > $gene.aligned.fasta
```

### Alignment trimming
Step 1: Perform [heads-or-tails alignment](https://doi.org/10.1093/molbev/msm060).
 
Step 2: Use [trimAl v.1.4](https://github.com/inab/trimal) to 
* discard inconsistent alignment positions between heads-and-tails alignments (given in fileset.txt, see code below)
* discard alignment positions that contain gaps in greater than 90% of the sequences (-gt 0.1)
* discard hypervariable alignment positions based on a nucleotide-similarity threshold of 0.001 (-st 0.001)
* discard entire sequences when less than 50% of their nucleotide characters have an overlap score of 0.5 (-resoverlap 0.5 -seqoverlap 0.5)

Example code:

```
trimal -compareset fileset.txt -out gene.trim_al.fasta -ct 0.5 -gt 0.1 -st 0.001 -resoverlap 0.5 -seqoverlap 0.5
```

### Removal of divergent regions
[TAPER v.0.1.6](https://github.com/chaoszhang/TAPER) was used to mask regions of individual sequences that were 
divergent outliers in comparison to the rest of the sequences in the alignment.

Example code:

```
correction_multi.jl gene.trim_al.fasta > gene_taper.fasta -c 1 -m N
```

### Paralog removal
Paralogs have the potential to confound downstream analyses, so to be cautious, all genes flagged by HybPiper as containing potential paralogs were removed from the dataset. This can be done by writing a simple bash script.

Example code:

```
while read paralog
do
rm $paralog*
done < /projects/cirsium/01_input/namelists/paralog_list.txt
```

## Phylogenetic analysis
### Concatenation approach
Using a concatenation approach, all sequence alignment files were concatenated into a single super-matrix using [AMAS v.1.0](https://github.com/marekborowiec/AMAS). Phylogenetic trees were then calculated from this single super-matrix.

Example code (concatenates all fasta files in the current directory into a single super-matrix alignment file):

```
AMAS.py concat -f fasta -d dna -i *.fasta
```
#### Maximum likelihood
Parametric analysis using maximum likelihood was conducted with [IQTREE v.2.1.3](https://github.com/Cibiv/IQ-TREE)

Example code:

```
iqtree -T AUTO -s concatenated.fasta -m MFP -B 1000
```

The option [T-AUTO] auto-detects how many cores/threads were specified when running the job on an HPC cluster.


#### Parsimony
Non-parametric analysis using parsimony was conducted with the command-line version of [TNT v.1.5](http://www.lillo.org.ar/phylogeny/tnt/). Scripts for running tree searches and calculating jackknife support values can be found [here]:

### Coalescent approach
Using a coalescent approach, individual gene trees were calculated, and a species tree estimated from these results using [ASTRAL v.5.7.8](https://github.com/smirarab/ASTRAL). Individual genes trees were calculated using the non-parametric approach as described above (TNT), but can also be done with a parametric approach. Once each invidivual gene tree had been calculated, they were concatenated into a single file (use the cat command), and analysis was performed with ASTRAL.

Example code:

```
java -jar astral.5.7.7.jar -i concatenated.tre -o out.astral.tre
```
## Population genomics analysis
The following results are not found in the manuscript, but were conducted out of curiosity about the dataset.
### Variant calling
I followed this tutorial to call variants and create a VCF file for population genomics analysis: (https://speciationgenomics.github.io/)
An exploration of the variant based statistics produced from my dataset using R can be found here: [R Markdown](https://github.com/rosenam/cirsium-2022/blob/main/vcf_analysis.Rmd) or [PDF](https://github.com/rosenam/cirsium-2022/blob/main/vcf_analysis.pdf).

### Population structure detection
I searched for genomic population structure with the unsupervised clustering algorithm [Admixture](https://dalexander.github.io/admixture/)

The admixture plots created for my dataset for K=2 through K=5 can be viewed in this [PDF](https://github.com/rosenam/cirsium-2022/blob/main/admixture_plotting.pdf) document, and the relevant code can be viewed in this [R Markdown](https://github.com/rosenam/cirsium-2022/blob/main/admixture_plotting.rmd) document.
