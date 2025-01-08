#!/bin/bash -l

module use /apps/leuven/rocky8/skylake/2018a/modules/all
module load HTSlib
module load Python/3.7.2-foss-2018a
module load BCFtools


BASE="pass_SVs_nochr_GRCh38_HG2-T2TQ100-V1.1_stvar.vcf.gz"
bed="nochr_GRCh38_HG2-T2TQ100-V1.1_stvar.benchmark.bed"

sample=""

# retain only PASS; INS DEL DUP

bgzip $sample.vcf
tabix $sample.vcf.gz

bcftools view -O z -f PASS -i 'INFO/SVTYPE="DEL,INS,DUP"' $sample.vcf.gz > filtered_INS_DEL_DUP_$sample.vcf.gz

tabix filtered_INS_DEL_DUP_$sample.vcf.gz

conda activate truvari

mkdir -p tmp/
export TMPDIR="tmp/"
truvari bench -b $BASE -c filtered_INS_DEL_DUP_$sample.vcf.gz -o output_dir/ --includebed $bed --dup-to-ins --pctseq 0




