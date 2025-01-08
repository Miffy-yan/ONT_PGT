#!/bin/bash

baseline_4_2_1="rename.HG002_GRCh38_1_22_v4.2.1_benchmark_phased_MHCassembly_StrandSeqANDTrio.vcf.gz"
bed_4_2_1="HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed"
template="hg38_SDF"


vcf=merge_output.vcf.gz

rtg-tools-3.12.1/rtg vcfeval \
-b $baseline_4_2_1 \
-c $vcf  \
--evaluation-regions $bed_4_2_1 \
-t $template \
-o vcf_eval \
--no-gzip  \
--vcf-score-field=GQ \
--roc-subset=snp \
--roc-subset=hom \
--roc-subset=het \
--roc-subset=mnp \
--roc-subset=indel \
--output-mode=roc-only 
