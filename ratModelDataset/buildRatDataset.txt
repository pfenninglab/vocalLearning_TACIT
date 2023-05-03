# train model from rat 


# positive reproducible peaks.
ratEnh=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed


# negative set: map macaque to rat, map bat to rat

ratEnh=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed

halLiftover=/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover 
wd=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel
xd=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/
cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools

ratPeak=/projects/MPRA/Irene/rats/atac-pipeline-output/Striatum/atac/63d3a234-a3cd-494b-becb-967a8ed60a04/call-call_peak_pooled/execution/R2-Str_R1_001.trim.merged.nodup.no_chrM.tn5.pooled.pval0.01.300K.bfilt.narrowPeak.gz

# 1 halLiftover macaque to rat
$halLiftover --bedType 4 $cacAlign \
Macaca_mulatta ${xd}/maca_Enhancer_GenB.bed \
Rattus_norvegicus ${wd}/macaqueMapRat_halliftover.narrowpeak

$halLiftover --bedType 4 $cacAlign \
Macaca_mulatta ${xd}/macMapHuman_Peaks_summits.bed \
Rattus_norvegicus ${wd}/macaqueMapRat_summits_halliftover.narrowpeak

python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile ${xd}/maca_Enhancer_GenB.bed -tFile ${wd}/macaqueMapRat_halliftover.narrowpeak \
-sFile ${wd}/macaqueMapRat_summits_halliftover.narrowpeak \
-oFile ${wd}/macaqueMapRat_HALPER.narrowpeak -narrowPeak

$bedtools intersect -a ${wd}/macaqueMapRat_HALPER.narrowpeak -b $ratPeak -v > ${wd}/macaqueMapRat_final.narrowpeak


# 2 halLiftover bat to rat

$halLiftover --bedType 4 $cacAlign \
Rousettus_aegyptiacus ${xd}/bat_cacform.bed \
Rattus_norvegicus ${wd}/batMapRat_halliftover.narrowpeak

$halLiftover --bedType 4 $cacAlign \
Rousettus_aegyptiacus ${xd}/bat_summit_cacform.bed \
Rattus_norvegicus ${wd}/batMapRat_summits_halliftover.narrowpeak

python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile ${xd}/bat_cacform.bed -tFile ${wd}/batMapRat_halliftover.narrowpeak \
-sFile ${wd}//batMapRat_summits_halliftover.narrowpeak \
-oFile ${wd}/batMapRat_HALPER.narrowpeak -narrowPeak

$bedtools intersect -a ${wd}/batMapRat_HALPER.narrowpeak -b $ratPeak -v > ${wd}/batMapRat_final.narrowpeak



# check rat to mouse distance
$halLiftover --bedType 4 $cacAlign \
Rattus_norvegicus $ratEnh \
Mus_musculus ${wd}/ratMapMouse_halliftover.narrowpeak

$halLiftover --bedType 4 $cacAlign \
Rattus_norvegicus ${xd}/ratMapHuman_Peaks_summits.bed \
Mus_musculus ${wd}/ratMapMouse_summits_halliftover.narrowpeak

python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile $ratEnh -tFile ${wd}/ratMapMouse_halliftover.narrowpeak \
-sFile ${wd}/ratMapMouse_summits_halliftover.narrowpeak \
-oFile ${wd}/ratMapMouse_HALPER.narrowpeak -narrowPeak


# Merge negatives
# negative 14431 + 19596 = 34027
# positive 28341 

batNeg=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/batMapRat_final.narrowpeak
MacaqueNeg=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/macaqueMapRat_final.narrowpeak

cat $batNeg $MacaqueNeg >> evaluate_1_negative.narrowpeak
sort -u -k1,1 -k2,2n -k3,3n -k10,10n evaluate_1_negative.narrowpeak > rat_evaluate_1_negative.narrowpeak




cat rat_neg_train.narrowpeak additionalEvaluate/ratModel_evaluate_3_negative_trainC.bed > rat_neg_train_merged.bed
sort -u -k1,1 -k2,2n -k3,3n -k10,10n rat_neg_train_merged.bed > rat_neg_train_mergeSort.bed

cat rat_neg_validate.narrowpeak  additionalEvaluate/ratModel_evaluate_3_negative_validationC.bed > rat_neg_val_merged.bed
sort -u -k1,1 -k2,2n -k3,3n -k10,10n rat_neg_val_merged.bed > rat_neg_val_mergeSort.bed

cat rat_pos_validate.narrowpeak  additionalEvaluate/ratModel_evaluate_3_positive_validationC.bed > rat_pos_val_merged.bed
sort -u -k1,1 -k2,2n -k3,3n -k10,10n rat_pos_val_merged.bed > rat_pos_val_mergeSort.bed

for i in *mergeSort*;
do python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i $i -o ${i%.*}_extended.bed -l 500;
done

for i in *mergeSort*; do echo ${i%.*}_extended.bed; done



