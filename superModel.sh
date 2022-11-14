
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py


# Training data for macaque and bat
#macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
#macaqueTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic_andhg38.transcript.geneNames_TSSWithStrand_sorted_UCSCNames.bed
#macaqueExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic.protCDS_geneNames_UCSCNames.bed

macaquePutamen=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/maca_Enhancer_GenB.bed

sbatch $mapPeak -i macaquePutamen_Genbank.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_positive_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaquePutamen_Genbank.bed  --peakListFileName macaqueMapRat_positive_train.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_macaque_positive_train.bed
# 27350
python $filterPeak --unfilteredPeakFileName macaquePutamen_Genbank.bed  --peakListFileName macaqueMapRat_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName superModel_macaque_positive_validate.bed
# 3155 

convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
python $convChName --bedFileName superModel_macaque_positive_train_500p.bed --chromNameDictFileName $genBank \
--outputFileName superModel_macaque_positive_train_500p_n.bed
python $convChName --bedFileName superModel_macaque_positive_validate_500p.bed --chromNameDictFileName $genBank \
--outputFileName superModel_macaque_positive_validate_500p_n.bed

python $convChName --bedFileName macaquePutamen_Genbank.bed --chromNameDictFileName $genBank \
--outputFileName macaquePutamen.bed


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

batPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/batPositive/bat_putamen_cactus.bed

macaquePeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz

# macaque negative1: bat to macaque; remove macaque
sbatch $mapPeak -i batPutamen_cactus.bed -f Rousettus_aegyptiacus -t Macaca_mulatta
python $convChName --bedFileName Rousettus_aegyptiacusMapToMacaca_mulatta_halper.narrowpeak --chromNameDictFileName $genBank \
--outputFileName batToMacaque_genbank.bed
bedtools intersect -a batToMacaque_genbank.bed -b $macaquePeak -v > batToMacaque_filtered.bed
python $convChName --bedFileName batToMacaque_filtered.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName batToMacaque_cactus.bed

sbatch $mapPeak -i batToMacaque_cactus.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueToRat_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueToRat_validate.bed
else
echo ${array[@]} | tr " " "\t" >> macaqueToRat_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName batToMacaque_filtered.bed --peakListFileName macaqueToRat_train.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_train_1.bed
python $filterPeak --unfilteredPeakFileName batToMacaque_filtered.bed --peakListFileName macaqueToRat_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_validate_1.bed


# macaque negative 2: rat to macaque; remove macaque; map to rat for separtation
sbatch $mapPeak -i rat_putamen_enhancer.bed -f Rattus_norvegicus -t Macaca_mulatta

python $convChName --bedFileName Rattus_norvegicusMapToMacaca_mulatta_halper.narrowpeak --chromNameDictFileName $genBank \
--outputFileName ratToMacaque_cn.bed
macaquePeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
bedtools intersect -a ratToMacaque_cn.bed -b $macaquePeak -v > ratToMacaque_cn_filtered.bed
python $convChName --bedFileName ratToMacaque_cn_filtered.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName ratToMacaque_gb.bed

sbatch $mapPeak -i ratToMacaque_gb.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueToRat_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueToRat_validate.bed
else
echo ${array[@]} | tr " " "\t" >> macaqueToRat_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName ratToMacaque_cn_filtered.bed --peakListFileName macaqueToRat_train.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_train_2.bed
python $filterPeak --unfilteredPeakFileName ratToMacaque_cn_filtered.bed --peakListFileName macaqueToRat_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_negative_validate_2.bed


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

python $convChName --bedFileName ratToBat_filtered.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName bat_enhancer_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' bat_enhancer_Seqname.bed > bat_enhancer_Seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
liftOver bat_enhancer_Seqname_int.bed $chainFile bat_putamen_lifted.bed bat_putamen_unlifted.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_putamen_lifted.bed > bat_putamen_lifted_genbank.bed
python $convChName --bedFileName bat_putamen_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_putamen_cactus.bed

sbatch $mapPeak -i bat_putamen_cactus.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName ratToBat_filtered.bed --peakListFileName mapToBat_negative_train.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_train_1.bed

python $filterPeak --unfilteredPeakFileName ratToBat_filtered.bed --peakListFileName mapToBat_negative_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_validate_1.bed

# 2. macaque to bat and remove bat
macaquePutamen=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/maca_Enhancer_GenB.bed

sbatch $mapPeak -i macaque_enhancer.bed -f Macaca_mulatta -t Rousettus_aegyptiacus

batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName Macaca_mulattaMapToRousettus_aegyptiacus_halper.narrowpeak --chromNameDictFileName $batCactusFormat \
--outputFileName macaqueToBatTrain_genBank.bed
awk 'BEGIN{OFS="\t"} {print substr($1, 1, length($1)-2) , $2, $3, $4, $5, $6, $7, $8, $9, $10}' macaqueToBatTrain_genBank.bed > macaqueToBatTrain_genBank_1.bed
batChain=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/RouAeg1.HLrouAeg4.over.chain.gz
liftOver macaqueToBatTrain_genBank_1.bed $batChain macaqueToBatTrain_lifted.narrowpeak macaqueToBatTrain_unlifted.narrowpeak

seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName macaqueToBatTrain_lifted.narrowpeak --chromNameDictFileName $seqName \
--outputFileName macaqueToBatTrain_named.bed
bedtools intersect -a  macaqueToBatTrain_named.bed -b $batPeak -v > macaqueToBat_filtered.bed

python $convChName --bedFileName macaqueToBat_filtered.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName bat_enhancer_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' bat_enhancer_Seqname.bed > bat_enhancer_Seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
liftOver bat_enhancer_Seqname_int.bed $chainFile bat_putamen_lifted.bed bat_putamen_unlifted.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_putamen_lifted.bed > bat_putamen_lifted_genbank.bed
python $convChName --bedFileName bat_putamen_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_putamen_cactus.bed

sbatch $mapPeak -i bat_putamen_cactus.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> mapToBat_negative_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueToBat_filtered.bed --peakListFileName mapToBat_negative_train.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_train_2.bed

python $filterPeak --unfilteredPeakFileName macaqueToBat_filtered.bed --peakListFileName mapToBat_negative_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_negative_validate_2.bed

