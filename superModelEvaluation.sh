filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py

# Evaluation 1: rat liver specific
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/additionalEvaluate/ratModel_evaluate_2_negative_validationC_500p.bed 
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/additionalEvaluate/ratModel_evaluate_2_positive_validationC_500p.bed
# Evaluation 2: rat cortex specific
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/additionalEvaluate/ratModel_evaluate_3_negative_validationC_500p.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/additionalEvaluate/ratModel_evaluate_3_positive_validationC_500p.bed
# Evaluation 3: macaque liver specific
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/macaqueLiverNeg/ratModel_val5_macaqueLiver_negative_validate_500p_a.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/ratModel_val5_macaqueLiver_positive_validate_500p_a.bed
# Evaluation 4: macaque cortex specific
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/macaqueCortexNeg/ratModel_val6_macaqueCortex_negative_validate_500p.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/macaqueCortexPos/ratModel_val6_macaqueCortex_positive_validate_500p.bed
# Evaluation 5: bat cortex specific
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/batCortexNeg/ratModel_val7_batCortex_negative_validate_500bp.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/batCortexPos/ratModel_val7_batCortex_positive_validate_500bp.bed
# Evaluation 6: rat specifc enhancer
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/ratSpecific/evaluation6_rat_specific_negative_500.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/ratSpecific/evaluation6_rat_specific_positive_500.bed
# Evaluation 7: macaque specific enhancer
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/macaqueSpecific/evaluation7_macaque_specific_negative_500.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/macaqueSpecific/evaluation7_macaque_specific_positive_500.bed
# Evaluation 8: bat specific enhancer
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/batSpecific/evaluation8_bat_specific_negative_500.bed
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/evaluation/batSpecific/evaluation8_bat_specific_positive_500.bed


# Evaluation 6: Rat specific enhancer

# positive: rat specific enhancer: rat enhancer whose bat + macaque ortholog is not enhancer
# map rat to bat & macaque, filter bat & macaque

## rat to macaque, filtered macaque, validation
ratToMacaque=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/macaque_negative_validate_2.bed
ratEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/rat_putamen_enhancer.bed
python $filterPeak --unfilteredPeakFileName $ratEnhancer --peakListFileName $ratToMacaque --unfilteredPeakNameCol 3 \
--outputFileName ratSpecfic_macaque.bed

## rat to bat, filtered bat
ratToBat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/ratToBat/ratToBat_filtered.bed

python $filterPeak --unfilteredPeakFileName ratSpecfic_macaque.bed --peakListFileName $ratToBat --unfilteredPeakNameCol 3 \
--outputFileName evaluation6_rat_specific_positive.bed

# Negative: non enhancer ortholog of rat that is enhancer in bat & macaque
# map macaque & bat to rat, filter rat

## Macaque mapped to rat
macaqueToRat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/Macaca_mulatta_MapTo_Rattus_norvegicus_halper.narrowpeak
## filter out rat
bedtools intersect -a $macaqueToRat -b $ratEnhancer -v > rat_nonEnhancer_macaque.bed

## bat mapped to rat
batToRat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/tmpFiles/Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak
## non enhancer ortholog of rat in macaque overlap bat
bedtools intersect -a rat_nonEnhancer_macaque.bed -b $batToRat -v > rat_nonEnhancer_overlap.bed
## limit to validation 
macaqueValidation=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/superModel_macaque_positive_validate.bed
python $filterPeak --unfilteredPeakFileName rat_nonEnhancer_overlap.bed --peakListFileName $macaqueValidation --unfilteredPeakNameCol 3 \
--outputFileName evaluation6_rat_specific_negative.bed

python $extendPeak expand_peaks -i evaluation6_rat_specific_negative.bed \
-o evaluation6_rat_specific_negative_500.bed -l 500

python $extendPeak expand_peaks -i evaluation6_rat_specific_positive.bed \
-o evaluation6_rat_specific_positive_500.bed -l 500

# Evaluation 7: Macaque specific enhancer

# positive: map macaque to rat & bat, filter rat & bat
macaqueEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/macaque_putamen_enhancer.bed
python $filterPeak --unfilteredPeakFileName $macaqueEnhancer --peakListFileName rat_nonEnhancer_macaque.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_specific_rat.bed
## overlap macaque to bat filtered bat
macaqueToBat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/macaqueToBat/halper/macaqueToBat_filtered.bed
python $filterPeak --unfilteredPeakFileName macaque_specific_rat.bed --peakListFileName $macaqueToBat --unfilteredPeakNameCol 3 \
--outputFileName macaque_specific_overlap.bed
## limit to validation
python $filterPeak --unfilteredPeakFileName macaque_specific_overlap.bed --peakListFileName $macaqueValidation --unfilteredPeakNameCol 3 \
--outputFileName evaluation7_macaque_specific_positive.bed


# negative: non-enhancer ortholog of macaque in both rat & bat
## bat to macaque, filtered macaque
batTomacaque=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/batToMacaque_filtered.bed
## rat to macaque, filtered macaque
ratToMacaque=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/ratToMacaque_cn_filtered.bed
## Overlap bat & rat
bedtools intersect -a $ratToMacaque -b $batTomacaque > macaque_nonEnhancer_overlap.bed

bedtools intersect -a $batTomacaque -b $ratToMacaque > tmp.bed
## limit to validation
ratValidation=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/rat_putamen_positive_validate.bed
python $filterPeak --unfilteredPeakFileName macaque_nonEnhancer_overlap.bed --peakListFileName $ratValidation --unfilteredPeakNameCol 3 \
--outputFileName evaluation7_macaque_specific_negative.bed


python $extendPeak expand_peaks -i evaluation7_macaque_specific_negative.bed \
-o evaluation7_macaque_specific_negative_500.bed -l 500

python $extendPeak expand_peaks -i evaluation7_macaque_specific_positive.bed \
-o evaluation7_macaque_specific_positive_500.bed -l 500

# Evaluation 8: Bat specific enhancer

# positive: bat enhancer intersects rat, intersects macaque
# map bat to rat & macaque, filter rat & macaque
batEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/bat_enhancer_named.bed
python $filterPeak --unfilteredPeakFileName $batEnhancer --peakListFileName $batTomacaque --unfilteredPeakNameCol 3 \
--outputFileName bat_specific_macaque.bed
python $filterPeak --unfilteredPeakFileName bat_specific_macaque.bed --peakListFileName $batToRat --unfilteredPeakNameCol 3 \
--outputFileName bat_specific_overlap.bed
##limit to validation
batValidation=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/batMapRat_positive_validate.bed
python $filterPeak --unfilteredPeakFileName bat_specific_overlap.bed --peakListFileName $batValidation --unfilteredPeakNameCol 3 \
--outputFileName evaluation8_bat_specific_positive.bed

# negative: map rat & macaque to bat, filter bat 
bedtools intersect -a $ratToBat -b $macaqueToBat > bat_nonEnhancer_overlap.bed
python $filterPeak --unfilteredPeakFileName bat_nonEnhancer_overlap.bed --peakListFileName $ratValidation --unfilteredPeakNameCol 3 \
--outputFileName evaluation8_bat_specific_negative.bed

python $extendPeak expand_peaks -i evaluation8_bat_specific_negative.bed \
-o evaluation8_bat_specific_negative_500.bed -l 500

python $extendPeak expand_peaks -i evaluation8_bat_specific_positive.bed \
-o evaluation8_bat_specific_positive_500.bed -l 500


# evaluations 9-11 (from rat model)
# positive: putamen not cortex
# negative: cortex not putamen



#Evaluation in rat shared by macaque and rat
# counter glires evaluations. 
# positives: map macaque to rat, overlap rat, remove bat
# map shared set to bat and remove bat, filter from rat.
# negatives: map bat to rat, remove rat, map bat to macaque. remove macaque. overlap. 
# evaluation 12

## Macaque mapped to rat
macaqueToRat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/Macaca_mulatta_MapTo_Rattus_norvegicus_halper.narrowpeak
ratEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/rat/rat_putamen_enhancer.bed
ratValidate=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/rat/rat_putamen_positive_validate.bed
## overlap rat
bedtools intersect -a $ratEnhancer -b $macaqueToRat -wa > rat_OverlapMacaque.bed

## remove bat
sbatch ~/codes/mapPeak.sh -i rat_OverlapMacaque.bed -f Rattus_norvegicus -t Rousettus_aegyptiacus

python $filterPeak --unfilteredPeakFileName rat_OverlapMacaque.bed --peakListFileName $ratValidate --unfilteredPeakNameCol 3 \
--outputFileName rat_overlapMacaque_validate.bed 
python $filterPeak --unfilteredPeakFileName rat_overlapMacaque_validate.bed --peakListFileName Rattus_norvegicus_MapTo_Rousettus_aegyptiacus_halper.narrowpeak --unfilteredPeakNameCol 3 \
--removePeaks --outputFileName counterGlires_positive.bed 
python $extendPeak expand_peaks -i counterGlires_positive.bed \
-o evaluation_12_counterGlires_positive_500.bed -l 500

sort -u -k1,1 -k2,2n -k3,3n -k10,10n counterGlires_positive.bed > tmp.bed
#negative
batToRat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/tmpFiles/Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak
bedtools intersect -a $batToRat -b $ratEnhancer -v > batToRat_filterRat.bed
batTomacaque=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/batToMacaque_filtered.bed

python $filterPeak --unfilteredPeakFileName batToRat_filterRat.bed --peakListFileName $batTomacaque --unfilteredPeakNameCol 3 \
--outputFileName bat_filterRatMacaque_overlap.bed 

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >>  counterGlires_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >>  counterGlires_negative_validate.bed
fi
done < bat_filterRatMacaque_overlap.bed

python $extendPeak expand_peaks -i counterGlires_negative_validate.bed \
-o evaluation_12_counterGlires_negative_500.bed -l 500

