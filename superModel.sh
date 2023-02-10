mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh

filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py

# Rat positives
ratEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/RatAtac/Striatum/call-reproducibility_idr/execution/idr.optimal_peak_nonCDS_enhancerShort.bed
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, "rat_"$4, $5, $6, $7, $8, $9, $10}' idr.optimal_peak_nonCDS_enhancerShort.bed > rat_putamen_enhancer.bed
while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >>  rat_putamen_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >>  rat_putamen_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >>  rat_putamen_positive_train.bed
fi
done < rat_putamen_enhancer.bed


# Macaque Positives
macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
macaqueTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic_andhg38.transcript.geneNames_TSSWithStrand_sorted_UCSCNames.bed
macaqueExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic.protCDS_geneNames_UCSCNames.bed

bedtools window -a $macaquePutamen -b $macaqueTSS -v -w 20000 | 
bedtools intersect -a stdin -b $macaqueExon -v > macaquePutamen_filter1.bed

while IFS=$'\t' read -r -a array; do
if (( $((${array[2]}-${array[1]})) > 1000 )); then
continue
else
echo ${array[@]} | tr " " "\t" >> macaquePutamen_filter2.bed 
fi
done < macaquePutamen_filter1.bed

sort -u -k1,1 -k2,2n -k3,3n -k10,10n macaquePutamen_filter2.bed |
awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_"i, $5, $6, $7, $8, $9, $10}//{i++}'  > macaque_putamen_enhancer.bed

#### Macaque Putamen
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/macaque_putamen_enhancer.bed
#### Macaque GenBank
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/halper/macaque_putamen_enhancer_genbank.bed

convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt

python $convChName --bedFileName macaque_putamen_enhancer.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName macaque_putamen_enhancer_genbank.bed

sbatch ~/codes/mapPeak.sh -i macaque_putamen_enhancer_genbank.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_train.bed
fi
done < Macaca_mulatta_MapTo_Rattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaque_putamen_enhancer.bed --peakListFileName macaqueMapRat_positive_train.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_macaque_positive_train.bed
# 27350
python $filterPeak --unfilteredPeakFileName macaque_putamen_enhancer.bed --peakListFileName macaqueMapRat_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_macaque_positive_validate.bed
# 3155 
python $filterPeak --unfilteredPeakFileName macaque_putamen_enhancer.bed --peakListFileName macaqueMapRat_positive_test.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_macaque_positive_test.bed

# Bat positive
batPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-reproducibility_idr/execution/idr.optimal_peak.narrowPeak.gz
batTss=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.transcriptAndHumanLiftover.geneNames_TSSWithStrand_sorted.bed
batExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.CDS.geneNames.bed

$bedtools window -a $batPeak -b $batTss -v -w 20000 | 
$bedtools intersect -a stdin -b $batExon -v > batPeak.fil.bed
while IFS=$'\t' read -r -a array; do
if (( $((${array[2]}-${array[1]})) > 1000 )); then
continue
else
echo ${array[@]} | tr " " "\t" >> batPeak.filSuperEnhancer.bed 
fi
done < batPeak.fil.bed
sort -u -k1,1 -k2,2n -k3,3n -k10,10n batPeak.filSuperEnhancer.bed > batPeak.filtered.final.bed
awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "bat_"i, $5, $6, $7, $8, $9, $10}//{i++}' batPeak.filtered.final.bed > bat_enhancer_named.bed

# Make cactus form of bat enhancers
seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName bat_enhancer_named.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName bat_enhancer_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' bat_enhancer_Seqname.bed > bat_enhancer_Seqname_int.bed
liftOver=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/liftOver
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
$liftOver bat_enhancer_Seqname_int.bed $chainFile bat_putamen_lifted.bed bat_putamen_unlifted.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_putamen_lifted.bed > bat_putamen_lifted_genbank.bed
python $convChName --bedFileName bat_putamen_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_putamen_cactus.bed

# Map bat to rat
sbatch $mapPeak -i bat_putamen_cactus.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> batMapRat_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> batMapRat_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> batMapRat_positive_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName bat_enhancer_named.bed --peakListFileName batMapRat_positive_train.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_bat_positive_train.bed
# 19186
python $filterPeak --unfilteredPeakFileName bat_enhancer_named.bed --peakListFileName batMapRat_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_bat_positive_validate.bed
# 2226



# Training Negatives: non enhancer orthologs of macaque

# mapping rat and bat peaks to macaque and then removing all macaque peaks.

mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt

##
batEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/bat_putamen_cactus.bed
##
macaquePeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz

# macaque negative1: bat to macaque; remove macaque
sbatch $mapPeak -i batPutamen_cactus.bed -f Rousettus_aegyptiacus -t Macaca_mulatta

python $convChName --bedFileName Rousettus_aegyptiacusMapToMacaca_mulatta_halper.narrowpeak --chromNameDictFileName $genBank \
--outputFileName batToMacaque_genbank.bed
bedtools intersect -a batToMacaque_genbank.bed -b $macaquePeak -v > batToMacaque_filtered.bed

batValidate=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/superModel_bat_positive_validate.bed
batTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/batMapRat_positive_train.bed
batTest=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/batMapRat_positive_test.bed

python $filterPeak --unfilteredPeakFileName batToMacaque_filtered.bed --peakListFileName $batTrain --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_train_1.bed
python $filterPeak --unfilteredPeakFileName batToMacaque_filtered.bed --peakListFileName $batValidate --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_validate_1.bed
python $filterPeak --unfilteredPeakFileName batToMacaque_filtered.bed --peakListFileName $test --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_test_1.bed


# macaque negative 2: rat to macaque; remove macaque; 
sbatch $mapPeak -i rat_putamen_enhancer.bed -f Rattus_norvegicus -t Macaca_mulatta

python $convChName --bedFileName Rattus_norvegicusMapToMacaca_mulatta_halper.narrowpeak --chromNameDictFileName $genBank \
--outputFileName ratToMacaque_cn.bed
bedtools intersect -a ratToMacaque_cn.bed -b $macaquePeak -v > ratToMacaque_cn_filtered.bed

python $filterPeak --unfilteredPeakFileName ratToMacaque_cn_filtered.bed --peakListFileName rat_putamen_positive_train.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_train_2.bed
python $filterPeak --unfilteredPeakFileName ratToMacaque_cn_filtered.bed --peakListFileName rat_putamen_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_validate_2.bed

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/macaque_negative_train_2.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/macaque_negative_train_1.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_train_nonEnhancer.bed 

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/macaque_negative_validate_2.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/macaque_negative_validate_1.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_validate_nonEnhancer.bed


# Bat Training neagtive: non enhancer ortholog of bat
# 1. rat to bat and remove bat
sbatch $mapPeak -i rat_putamen_enhancer.bed -f Rattus_norvegicus -t Rousettus_aegyptiacus

batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName Rattus_norvegicusMapToRousettus_aegyptiacus_halper.narrowpeak --chromNameDictFileName $batCactusFormat \
--outputFileName ratToBatTrain_genBank.bed
awk 'BEGIN{OFS="\t"} {print substr($1, 1, length($1)-2) , $2, $3, $4, $5, $6, $7, $8, $9, $10}' ratToBatTrain_genBank.bed > ratToBatTrain_genBank_1.bed
batChain=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/RouAeg1.HLrouAeg4.over.chain.gz
liftOver ratToBatTrain_genBank_1.bed $batChain ratToBatTrain_lifted.narrowpeak ratToBatTrain_unlifted.narrowpeak

seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName ratToBatTrain_lifted.narrowpeak --chromNameDictFileName $seqName \
--outputFileName ratToBatTrain_named.bed

# remove all bat peaks
batPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz
bedtools intersect -a ratToBatTrain_named.bed -b $batPeak -v > ratToBat_filtered.bed


ratTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/rat_putamen_positive_train.bed
ratVal=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/rat_putamen_positive_validate.bed
python $filterPeak --unfilteredPeakFileName ratToBat_filtered.bed --peakListFileName $ratTrain --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_train_1.bed

python $filterPeak --unfilteredPeakFileName ratToBat_filtered.bed --peakListFileName $ratVal --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_validate_1.bed

# 2. macaque to bat and remove bat

sbatch ~/codes/mapPeak.sh -i macaque_putamen_enhancer_genbank.bed -f Macaca_mulatta -t Rousettus_aegyptiacus

sh ~/codes/batFormatConvert.sh -i Macaca_mulatta_MapTo_Rousettus_aegyptiacus_halper.narrowpeak -r

bedtools intersect -a Macaca_mulatta_MapTo_Rousettus_aegyptiacus_halper_convertedOriginal.bed -b $batPeak -v > macaqueToBat_filtered.bed

macaqueTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/superModel_macaque_positive_train.bed
macaqueValidate=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/superModel_macaque_positive_validate.bed

python $filterPeak --unfilteredPeakFileName macaqueToBat_filtered.bed --peakListFileName $macaqueTrain --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_train_2.bed

python $filterPeak --unfilteredPeakFileName macaqueToBat_filtered.bed --peakListFileName $macaqueValidate --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_validate_2.bed

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/ratToBat/bat_negative_train_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/macaqueToBat/bat_negative_train_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_train_nonEnhancer.bed

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/ratToBat/bat_negative_validate_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/macaqueToBat/bat_negative_validate_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_validate_nonEnhancer.bed
