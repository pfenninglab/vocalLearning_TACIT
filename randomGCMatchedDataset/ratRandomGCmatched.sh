awk 'BEGIN{OFS="\t"}{print $1, $2, $3, $4}' superModel_macaque_positive_train_500p_n.bed > superModel_macaque_positive_train_500p_4c.bed
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, $4}' superModel_macaque_positive_validate_500p_n.bed > superModel_macaque_positive_validate_500p_4c.bed



library("gkmSVM")
library("BSgenome.Rnorvegicus.UCSC.rn6.masked.full")
GCRepMatch <- genNullSeqs("
	/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/data/ratModelDataset/rat_pos_total_4col.bed
	", outputBedFN="/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/data/ratModelDataset/rat_total_randomGCRepeatMatched_10x.bed", xfold=10, length_match_tol=0.00, nMaxTrials=100, genome=BSgenome.Rnorvegicus.UCSC.rn6.masked.full)

install.packages("/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/putamenSupermodel/randomGC/BSgenome.Mmulatta.UCSC.rheMac8.masked.full/", repos=NULL, type="source")


 BiocManager::install(c('GenomicRanges','rtracklayer','BSgenome'),dependencies = TRUE)

# remove super enhancer
while IFS=$'\t' read -r -a array; do
if (( $((${array[2]}-${array[1]})) > 1000 )); then
continue
else
echo ${array[@]} | tr " " "\t" >> rat_randomGC_10x_rmPeak_rmSuperEnhancer.bed 
fi
done < rat_randomGC_10x_rmPeak.bed

# remove TSS overlaps
starts=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/RatGenome/GCF_000001895.5_Rnor_6.0_genomic.protTranscript_geneNames_TSSWithStrand_UCSCNames.bed
$bedtools window -a rat_randomGC_10x_rmPeak_rmSuperEnhancer.bed  -b $starts -v -w 20000 > rat_randomGC_10x_rmPeak_rmTSS.bed 

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3+1, "randomGC_Peak_"i, "-1", ".", "-1", "-1", "-1", "250"}//{i++}' rat_randomGC_10x_rmPeak_rmTSS.bed > rat_randomGC_matched.bed

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> rat_randomGC_matched_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> rat_randomGC_matched_validate.bed
else
echo ${array[@]} | tr " " "\t" >> rat_randomGC_matched_train.bed
fi
done <  rat_randomGC_matched.bed


cat rat_neg_train_mergeSort_extended.bed randomGC/rat_randomGC_matched_train.bed >> rat_neg_withRandomGC_train_tmp.bed
sort -u -k1,1 -k2,2n -k3,3n rat_neg_withRandomGC_train_tmp.bed > rat_neg_withRandomGC_train.bed

cat rat_neg_val_mergeSort_extended.bed randomGC/rat_randomGC_matched_validate.bed >> rat_neg_withRandomGC_validate_tmp.bed
sort -u -k1,1 -k2,2n -k3,3n rat_neg_withRandomGC_validate_tmp.bed > rat_neg_withRandomGC_validate.bed
