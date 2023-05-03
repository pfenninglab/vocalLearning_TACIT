macaque=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
rat=/projects/MPRA/Irene/rats/atac-pipeline-output/Striatum/atac/63d3a234-a3cd-494b-becb-967a8ed60a04/call-call_peak_pooled/execution/R2-Str_R1_001.trim.merged.nodup.no_chrM.tn5.pooled.pval0.01.300K.bfilt.narrowPeak.gz
bat=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz


filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
datadir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData
savedir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/evaluateDataset

# Additional validation set
# positive: macaque enhancers whose human orthologs are not enhancers.
# negative: macaque orthologs of human enhancers that are not enhancers

# 1 positive sets
# Keep the enhancers whose human orthologs are not enhancers, filter out the rest.

humanNegative=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/datasets/raw/putamen_neg_train.narrowpeak

cd $savedir
macaqueEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/maca_Enhancer_GenB.bed
python $filterPeak --unfilteredPeakFileName $macaqueEnhancer --peakListFileName $humanNegative --unfilteredPeakNameCol 3 \
--outputFileName humanMapMacaque_positive_val.narrowpeak

# Rename rat enhancer according to human negative file
ratEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, "rat_"$4, $5, $6, $7, $8, $9, $10}' $ratEnhancer > ratEnhancer.narrowpeak
python $filterPeak --unfilteredPeakFileName ratEnhancer.narrowpeak --peakListFileName $humanNegative --unfilteredPeakNameCol 3 \
--outputFileName humanMapRat_positive_val.narrowpeak

batEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/bat_cacform.bed
batHumanNegative=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/bat_MapHuman_Halper_final.bed
python $filterPeak --unfilteredPeakFileName $batEnhancer --peakListFileName $batHumanNegative --unfilteredPeakNameCol 3 \
--outputFileName humanMapBat_positive_val.narrowpeak

#  Macaque_positive_val size: 71003 > 19738
#  Rat_positive_val_size: 28341 > 6926
#  Bat_positive_val_size:  53689 > 20380


# 2 Negative sets

# Build Macaque negative validation dataset
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/datasets/putamen_pos_train_pro.narrowpeak

/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens $humanPeak Macaca_mulatta ${savedir}/humanMapMacaque.narrowpeak

awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}'  $humanPeak > ${savedir}/humanMap_summits.narrowpeak
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens ${savedir}/humanMap_summits.narrowpeak Macaca_mulatta ${savedir}/humanMapMacaque_summits_hal.narrowpeak

halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile $humanPeak -tFile ${savedir}/humanMapMacaque.narrowpeak  -sFile ${savedir}/humanMapMacaque_summits_hal.narrowpeak \
-oFile ${savedir}/humanMapMacaque_HALPER.narrowpeak -narrowPeak

data=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/evaluateDataset
macaquePeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
./bedtools intersect -a ${data}/humanMapMacaque_HALPER.narrowpeak -b $macaquePeak -v > ${data}/humanMapMacaque_negative_val.narrowpeak


# Build Rat negative validation dataset

/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens $humanPeak Rattus_norvegicus ${savedir}/humanMapRat.narrowpeak

/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens ${savedir}/humanMap_summits.narrowpeak Rattus_norvegicus ${savedir}/humanMapRat_summits_hal.narrowpeak
echo "finished halliftover"
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile $humanPeak -tFile ${savedir}/humanMapRat.narrowpeak  -sFile ${savedir}/humanMapRat_summits_hal.narrowpeak \
-oFile ${savedir}/humanMapRat_HALPER.narrowpeak -narrowPeak

# Build Bat negative validation set 
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens $humanPeak Rousettus_aegyptiacus ${savedir}/humanMapBat.narrowpeak

awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}'  ${savedir}/humanMapBat.narrowpeak > ${savedir}/humanMapBat_summits.narrowpeak
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Homo_sapiens ${savedir}/humanMap_summits.narrowpeak Rousettus_aegyptiacus ${savedir}/humanMapBat_summits_hal.narrowpeak

halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile $humanPeak -tFile ${savedir}/humanMapBat.narrowpeak  -sFile ${savedir}/humanMapBat_summits_hal.narrowpeak \
-oFile ${savedir}/humanMapBat_HALPER.narrowpeak -narrowPeak



# Merge three species with sort unique =
cat *negative_val.narrowpeak >> evaluate_1_negative.narrowpeak
cat *positive_val.narrowpeak >> evaluate_1_positive.narrowpeak

