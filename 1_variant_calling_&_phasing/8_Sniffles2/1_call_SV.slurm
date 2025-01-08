#!/bin/bash -l
#SBATCH --account="lp_joris_vermeesch"
#SBATCH --chdir="/user/leuven/339/vsc33900"
#SBATCH --error="xx/%x.e%A"
#SBATCH --output="xx/%x.o%A"
#SBATCH --export="NONE"
#SBATCH --get-user-env="60L"
#SBATCH --mail-type="BEGIN,END,FAIL,TIME_LIMIT"
#SBATCH --mail-user="yan.zhao1@student.kuleuven.be"
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes="1"
#SBATCH --ntasks-per-node="15"
#SBATCH --ntasks="15"
#SBATCH --time="5:00:00"

# submit job
# sbatch --cluster=genius xx.slurm

SAMPLE=""
TR_annotations="nochr_human_GRCh38_no_alt_analysis_set.trf.bed"
REF="/lustre1/project/stg_00019/genome/homo_sapiens/hg38/genome.fa"
bam="$SAMPLE.bam"

conda activate Sniffles2

sniffles -i $bam -v $SAMPLE.vcf \
--tandem-repeats $TR_annotations \
--reference $REF