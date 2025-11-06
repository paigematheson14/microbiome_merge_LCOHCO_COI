#!/bin/bash

for i in {1..135}; do 

#merge and filter; HCO 
vsearch -fastq_mergepairs HCO-${i}-R1.fastq.gz -reverse HCO-${i}-R2.fastq.gz -fastq_minovlen 100 -fastq_minmergelen 250 -fastq_maxmergelen 400 -fastq_maxee 1.0 -fastaout HCO-${i}.filtered.fasta;
#LCO
vsearch -fastq_mergepairs LCO-${i}-R1.fastq.gz -reverse LCO-${i}-R2.fastq.gz -fastq_minovlen 100 -fastq_minmergelen 250 -fastq_maxmergelen 400 -fastq_maxee 1.0 -fastaout LCO-${i}.filtered.fasta;

#dereplicate, denoise, remove chimeras; HCO then LCO
vsearch -derep_fulllength HCO-${i}.filtered.fasta -sizeout -output HCO-${i}.uniq.fasta
vsearch -cluster_unoise HCO-${i}.uniq.fasta -minsize 1 -sizein -sizeout -centroids HCO-${i}.denoise.fasta
vsearch -uchime3_denovo HCO-${i}.denoise.fasta -nonchimeras  HCO-${i}.denoise_no_chimera.fasta
#LCO
vsearch -derep_fulllength LCO-${i}.filtered.fasta -sizeout -output LCO-${i}.uniq.fasta
vsearch -cluster_unoise LCO-${i}.uniq.fasta -minsize 1 -sizein -sizeout -centroids LCO-${i}.denoise.fasta
vsearch -uchime3_denovo LCO-${i}.denoise.fasta -nonchimeras  LCO-${i}.denoise_no_chimera.fasta

#find most abundant sequence; HCO then LCO 
vsearch -derep_fulllength HCO-${i}.denoise_no_chimera.fasta -sizeout -topn 1 -output HCO-${i}.top1.fasta
#LCO
vsearch -derep_fulllength LCO-${i}.denoise_no_chimera.fasta -sizeout -topn 1 -output LCO-${i}.top1.fasta; 

done 

mkdir -p combined_amplicons

for i in {i..135}; do

#combine LCO and HCO fasta into one fasta and copy into a new folder 

cat HCO-${i}.top1.fasta LCO-${i}.top1.fasta > ${i}_LCO_and_HCO.fasta

cp ${i}_LCO_and_HCO.fasta ./combined_amplicons;

done

cd combined_amplicons/

for i in {1..135}; do 

#use allpairs_global to identify optimal alignments

vsearch -allpairs_global ${i}_LCO_and_HCO.fasta -id 0.92 -mincols 85 -blast6out ${i}_alignment_matches.txt;

done

#concatenate all of the alignment matches 
cat *_alignment_matches.txt > all_overlap.txt

#concatenate all of the HCO and LCO sequences
cat LCO-${i}.top1.fasta > all_LCO.fasta
cat HCO-${i}.top1.fasta > all_HCO.fasta


































