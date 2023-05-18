#!/bin/bash

# chmod 755 3_check_gene_exon_cover_for_data_and_ref.sh
# nohup 3_check_gene_exon_cover_for_data_and_ref.sh > 3_check_gene_exon_cover_for_data_and_ref.sh.log 2>&1 &
# r23i27n24
# 13964
module load BEDTools

uniq_exon_protein_coding_bed="/lustre1/project/stg_00019/research/yan/nanopore_data/00_02_resource_GENCODE/gtf_bed_files/nochr_uniq_exon_protein_coding.sorted.merged.bed"
uniq_gene_protein_coding_bed="/lustre1/project/stg_00019/research/yan/nanopore_data/00_02_resource_GENCODE/gtf_bed_files/nochr_uniq_gene_protein_coding.sorted.merged.bed"

wkdir="/lustre1/project/stg_00019/research/yan/nanopore_data/03_01_1_2_test_explore_PGT_M_merge_whole_vcf"

echo -e data"\t"len_snv_lim"\t"max_matchperc_lim"\t"exon_coverage"\t"gene_coverage>$wkdir/gene_exon_coverage.txt

for data in "GIAB_4_2_1_hifiasm_v11_phasetransfer" "bulk_no_10x_LSK110" "sc_PTA_10x_LSK110" "mc_PTA_4x_LSK110" "sc_MDA_24x_LSK110" "mc_MDA_23x_LSK110" "sc_MDA_22x_LSK114" "mc_MDA_24x_LSK114" "bulk_no_24x_LSK114"
do
cd $wkdir/$data

for len_snv_lim in 2 4 6
do
for max_matchperc_lim in 1 0.9 0.8 0.7 0.6 0
do

## 1.get phased block bed file --> GTF start positions -1 
cat b_"$data"_trio_success.txt|grep -v CHROM|sort -k1,1 -k2,2n|awk '$5>='''$len_snv_lim'''&& $21>='''$max_matchperc_lim'''&& $22>='''$max_matchperc_lim''' '|awk '{print $1"\t"$2-1"\t"$3}'>c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".bed


## 2. get overlapped regions between uniq_exon_protein_coding_bed (GENCODE) and the sample phased block bed file

bedtools intersect -a c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".bed \
                             -b $uniq_exon_protein_coding_bed>c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".exon.intersect.bed

## 3. get overlapped regions between uniq_gene_protein_coding_bed (GENCODE) and the sample phased block bed file      

bedtools intersect -a c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".bed \
                             -b $uniq_gene_protein_coding_bed>c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".gene.intersect.bed


#awk '{sum_bp+=$3-$2}END{print sum_bp}' $uniq_exon_protein_coding_bed
# 108522233
sum_exon_protein_coding=108522233
#awk '{sum_bp+=$3-$2}END{print sum_bp}' $uniq_gene_protein_coding_bed
# 1304978080
sum_gene_protein_coding=1304978080

## 4. check gen/exon coverage 

exon_coverage_bed=c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".exon.intersect.bed
exon_covered_success=`awk '{sum_bp+=$3-$2}END{print sum_bp}' $exon_coverage_bed`

gene_coverage_bed=c_"$data"_trio_success_lensnv_"$len_snv_lim"_max_matchperc_lim_"$max_matchperc_lim".gene.intersect.bed
gene_covered_success=`awk '{sum_bp+=$3-$2}END{print sum_bp}' $gene_coverage_bed`

exon_coverage=`echo -e $exon_covered_success"\t"$sum_exon_protein_coding|awk 'BEGIN { OFMT = "%.4f"} {print $1/$2}'`
gene_coverage=`echo -e $gene_covered_success"\t"$sum_gene_protein_coding|awk 'BEGIN { OFMT = "%.4f"} {print $1/$2}'`


echo -e $data"\t"$len_snv_lim"\t"$max_matchperc_lim"\t"$exon_coverage"\t"$gene_coverage>>$wkdir/gene_exon_coverage.txt

done
done
done



# --------------get max_matchperc stats----------------------
echo -e data"\t"min_max_matchperc_Ha"\t"min_max_matchperc_Hb"\t"perc_blocks_max_matchperc_Ha_Hb_1>$wkdir/min_max_matchperc.txt
for data in "GIAB_4_2_1_hifiasm_v11_phasetransfer" "bulk_no_10x_LSK110" "sc_PTA_10x_LSK110" "mc_PTA_4x_LSK110" "sc_MDA_24x_LSK110" "mc_MDA_23x_LSK110" "sc_MDA_22x_LSK114" "mc_MDA_24x_LSK114" "bulk_no_24x_LSK114"
do
cd $wkdir/$data

# Force a type conversion, using addition of zero
min_max_matchperc_Ha=`cat b_"$data"_trio_success.txt|grep -v CHROM|awk 'BEGIN{a=1}{if ($21<0+a) a=$21}END{print a}'`
min_max_matchperc_Hb=`cat b_"$data"_trio_success.txt|grep -v CHROM|awk 'BEGIN{a=1}{if ($22<0+a) a=$22}END{print a}'`

nrow=`cat b_"$data"_trio_success.txt|grep -v CHROM|wc -l`

perc_blocks_max_matchperc_Ha_Hb_1=`cat b_"$data"_trio_success.txt|grep -v CHROM|awk '$21==1&&$22==1'|awk -v nrow=$nrow 'END{print NR/nrow}'`


echo -e $data"\t"$min_max_matchperc_Ha"\t"$min_max_matchperc_Hb"\t"$perc_blocks_max_matchperc_Ha_Hb_1 >>$wkdir/min_max_matchperc.txt

done 