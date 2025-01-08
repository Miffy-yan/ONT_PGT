#!/bin/bash -l
#SBATCH --account="lp_joris_vermeesch"
#SBATCH --chdir="/user/leuven/339/vsc33900"
#SBATCH --error="xx/%x.e%A"
#SBATCH --output="xx/%x.o%A"
#SBATCH --export="NONE"
#SBATCH --get-user-env="60L"
#SBATCH --mail-type="BEGIN,END,FAIL,TIME_LIMIT"
#SBATCH --mail-user="yan.zhao1@student.kuleuven.be"
#SBATCH --mem-per-cpu=5G
#SBATCH --nodes="1"
#SBATCH --ntasks-per-node="4"
#SBATCH --ntasks="4"
#SBATCH --time="6:00:00"

# sbatch --cluster=genius get_chimeric_stats.slurm
# 

module use /apps/leuven/rocky8/skylake/2021a/modules/all
module load SAMtools/1.13-GCC-10.3.0  

bam="xx"
wkdir="xx"
cd $wkdir

# ---------1. output chimeric read QNAME---------
samtools view -f 0x800 $bam|awk '{print $1}'|sort|uniq>chimeric_qname.txt

# ---------2. output chimeric alignments primary+sup (no unmapped or multimapped)---------
samtools view -b -F 0x100 -F 0x4 -N chimeric_qname.txt -o chimeric_alignment.bam $bam

# ------------3. before splits chimeric read length-----------
# the length of the "seq" field in the primary alignment
samtools view chimeric_alignment.bam -F 2048\
|awk '{print length($10)}'>chimeric_read_len.txt

# ------------4. after split segment length-----------
# the length of soft clipped bases in the primary alignment
samtools view chimeric_alignment.bam -F 2048\
|awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"length($10)}'\
|cut -f 6|awk -F "[A-Z]" '{
if($0~/^[0-9]+S.*[0-9]+S/)
	print $1"\t"$(NF-1);
else if($0~/^[0-9]+S.*[^S]$/)
	print $1"\t"0;
else if($0~/^[^S].*[0-9]+S$/)
	print 0"\t"$(NF-1);
else if($0~/^[^S].*[^S]$/)
	print 0"\t"0;}'\
|awk '{print $1+$2}' > chimeric_S_clip.txt

# ------primary len--> chimeric_read_len-Soft_clipped 
# qlen-sclen: n bases used in the alignment
paste chimeric_read_len.txt chimeric_S_clip.txt\
|awk '{print $1-$2}' > primary_len.txt

# ---------other segment length--> the length of the "seq" field
samtools view chimeric_alignment.bam -f 2048\
|awk '{print length($10)}'>sup_len.txt

rm chimeric_qname.txt chimeric_alignment.bam chimeric_S_clip.txt