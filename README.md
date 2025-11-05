# microbiome_merge_LCOHCO_COI
This is how I merged the LCO and HCO barcodes into a COI barcode for species ID using VSEARCH

```ml VSEARCH```

# 1 - Merge R1 and R2 .fastq.gz files, and filter. You can automate these steps easily by setting up a bash loop (see below):

```
for num in {1..135}; do

vsearch -fastq_mergepairs ${num}-LC_S456_L001_R1_001.fastq.gz -reverse ${num}-LC_S456_L001_R2_001.fastq.gz -fastq_minovlen 200 -fastq_minmergelen 250 -fastq_maxmergelen 400 -fastq_maxee 1.0 -fastq_maxns 0 -fastaout 100-LC.filtered.fasta

vsearch -fastq_mergepairs ${num}-HCO_S527_L001_R1_001.fastq.gz -reverse ${num}-HCO_S527_L001_R2_001.fastq.gz -fastq_minovlen 100 -fastq_minmergelen 350 -fastq_maxmergelen 500 -fastq_maxee 1.0 -fastq_maxns 0 -fastaout 100-HCO.filtered.fasta;

done 
```

# 2 - Dereplicate (identify and remove redundant/near identical samples to create a set of unique sequences), denoise, check for chimeras

Again, should set up a bash loop as per #1 so that you need only run the line once! Do this for both HCO and LCO.

```for num in {1..135}; do
vsearch -derep_fulllength ${num}-HCO.filtered.fasta -relabel ${num}-HCO -sizeout -output ${num}-HCO.uniq.fasta
vsearch -cluster_unoise ${num}-HCO.uniq.fasta -relabel ${num}-HCO.denoise -minsize 1 -sizein -sizeout -centroids ${num}-HCO.denoise.fasta
vsearch -uchime3_denovo ${num}-HCO.denoise.fasta -nonchimeras  ${num}-HCO.denoise_no_chimera.fasta;
done
```

# 3 - Output single most abundant sequence (the sequence that is represented the most)

```
vsearch -derep_fulllength ${num}-HCO.denoise_no_chimera.fasta -relabel ${num}s.Uniq -sizeout -topn 1 -output ${num}s.top1.fasta 
```

# 4 - Identify optimal pairwise alignments between denoised sequences (need to rename FASTAs at this point; i.e., add amplcion labels so that they can be distinguished later)

I named mine HCO.i### and LCO.i### (where ### represents the sample number). Good to be consistent - can use awk to change FASTA headers. 

## Combine LCO and HCO sequences into one file per sample
``` 
for num in {1..135}; do 
cat ${num}_LCO.fasta ${num}_HCO.fasta > ${num}_LCO_and_HCO.fasta;
done
```

## Use allpairs_global to identify optimal alignments - THIS DIDN'T WORK FOR ME FOR AGES, I HAD TO MAKE THE PARAMETERS A BIT LESS STRICT (92% identity rather than 100%)
```
for num in {1..135}; do
vsearch -allpairs_global {num}_LCO_and_HCO.fasta -id 0.92 -mincols 85 -blast6out {num}_alignment_matches.txt;
done
```

## Concatenate all of the alignment matches 
```
cat *_alignment_matches.txt > all_overlap.txt
```

## Concatenate all of the HCO and LCO fragments
```
cat *_LCO.fasta > all_LCO.fasta
cat *_HCO.fasta > all_HCO.fasta
```

# 5 - Merge using custom script 
I wasn't able to get the seqs_to_barcodes.py script from Manaaki whenua to work, the taxonomic stuff wasn't working for my data (we were unsure what the species were, which was why we were sequencing for COI), so I used a script that merges them based on the longest overlap and then blasted them 



























