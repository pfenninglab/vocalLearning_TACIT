# Additional validation set for Rat model

filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools

# positive: macaque/bat enhancers whose rat orthologs are not enhancers.
ratNeg=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_neg_total.narrowpeak
batEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/bat_cacform.bed

macaqueUCSC=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/macaque_fil.bed

python $filterPeak --unfilteredPeakFileName $macaqueUCSC --peakListFileName $ratNeg --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val1_macaque_positive.narrowpeak

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" == "chr8" ] || [ "${array[0]}" == "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_val1_macaque_positive_val.narrowpeak
fi
done <  ratModel_val1_macaque_positive.narrowpeak

# use batk1 peaks. 
ratValNeg=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_neg_validate.narrowpeak
batK=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/bat_fil.bed
python $filterPeak --unfilteredPeakFileName $batK --peakListFileName $ratValNeg --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val1_bat_positive.narrowpeak



# negative

# map rat to macaque
ratEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_pos_total.narrowpeak

sbatch mapPeak.sh -i $ratEnhancer -f Rattus_norvegicus -t Macaca_mulatta 

# convert from GenBank to UCSC chromosome format
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
python $convChName --bedFileName rat_pos_total_halper.narrowpeak --chromNameDictFileName $genBank \
--outputFileName ratMapMacaque_UCSC.narrowpeak

# filter all macaque peaks
macaquePeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a ratMapMacaque_UCSC.narrowpeak -b $macaquePeak -v > ratMapMacaque_UCSC_filterPeak.narrowpeak

# limit to validation
while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" == "chr8" ] || [ "${array[0]}" == "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_val1_macaque_negative.narrowpeak
fi
done < macaqueMapRat_UCSC_filterPeak.narrowpeak


# Map rat to bat
mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
ratValPos=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_pos_validate.narrowpeak
sbatch $mapPeak -i $ratValPos -f Rattus_norvegicus -t Rousettus_aegyptiacus

# Map to bat1k
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName rat_pos_validate_halper.narrowpeak --chromNameDictFileName $batCactusFormat \
--outputFileName ratMapBat_genBank.narrowpeak

awk 'BEGIN{OFS="\t"} {print substr($1, 1, length($1)-2) , $2, $3, $4, $5, $6, $7, $8, $9, $10}' ratMapBat_genBank.narrowpeak > ratMapBat_genBank_1.narrowpeak

batChain=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/RouAeg1.HLrouAeg4.over.chain.gz
lift=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/liftOver
$lift ratMapBat_genBank_1.narrowpeak $batChain ratMapBat_lifted.narrowpeak ratMapBat_unlifted.narrowpeak

# convert back chromosome format
seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName ratMapBat_lifted.narrowpeak --chromNameDictFileName $seqName \
 --outputFileName ratMapBat_formatted.narrowpeak

# remove all bat peaks
batPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a ratMapBat_formatted.narrowpeak -b $batPeak -v > ratModel_val1_bat_negative.narrowpeak
