# All file paths
extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py

python $extendPeak expand_peaks -i superModel_bat_positive_validate.bed \
-o superModel_bat_positive_validate_500p.bed -l 500

python $extendPeak expand_peaks -i superModel_macaque_positive_validate.bed \
-o superModel_macaque_positive_validate_500p.bed -l 500

# superModel_bat_positive_train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/superModel_bat_positive_train_500p.bed
# superModel_bat_positive_validate
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/superModel_bat_positive_validate_500p.bed

# superModel_macaque_positive_train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/superModel_macaque_positive_train_500p.bed
# superModel_macaque_positive_validate
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/superModel_macaque_positive_validate_500p.bed

# macaque negative train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/superModel_macaque_negative_train.fa
# macaque negative validation
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/superModel_macaque_negative_validate.fa
# bat negative train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/superModel_bat_negative_train.fa
# bat negative validate
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/superModel_bat_negative_validate.fa

# UNPROCESSED negatives 
# Macaque negatives

# negative 3 GC train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/macaqueGC/macaque_putamen_randomGC_10x_train_500p.bed
# negative 3 GC validate 
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/macaqueGC/macaque_putamen_randomGC_10x_validate_500p.bed

# Merge mortor cortex into negatives
python $filterPeak --unfilteredPeakFileName macaqueCortex_negative_UCSC_named.bed  --peakListFileName ratModel_macaqueCortex_negative_train.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val6_macaqueCortex_negative_train.bed
python $convChName --bedFileName ratModel_val6_macaqueCortex_negative_train.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val6_macaqueCortex_negative_train_converted.bed
macaqueCortexTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/macaqueCortexNeg/ratModel_val6_macaqueCortex_negative_train_converted.bed
macaqueCortexValidate=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/macaqueCortexNeg/ratModel_val6_macaqueCortex_negative_validate_converted.bed


cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/macaque_negative_train_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/macaque_negative_train_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_train_nonEnhancer.bed

cat macaque_negative_train_nonEnhancer.bed $macaqueCortexTrain \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_train_nonEnhancer_cortex.bed

python $extendPeak expand_peaks -i macaque_negative_train_nonEnhancer_cortex.bed \
-o macaque_negative_train_nonEnhancer_500p.bed -l 500

macaqueGene=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/rheMac8.fa
bedtools getfasta -fi $macaqueGene -bed macaque_negative_train_nonEnhancer_500p.bed > macaque_negative_train_nonEnhancer_500p.fa

bedtools getfasta -fi $macaqueGene -bed /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/macaqueGC/macaque_putamen_randomGC_10x_train_500p.bed \
> macaque_putamen_randomGC_10x_train_500p.fa

cat macaque_negative_train_nonEnhancer_500p.fa macaque_putamen_randomGC_10x_train_500p.fa \
> superModel_macaque_negative_train.fa

# macaque negative validation
cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/batToMacaque/macaque_negative_validate_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/ratToMacaque/macaque_negative_validate_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_validate_nonEnhancer.bed

cat macaque_negative_validate_nonEnhancer.bed $macaqueCortexValidate \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > macaque_negative_validate_nonEnhancer_cortex.bed

python $extendPeak expand_peaks -i macaque_negative_validate_nonEnhancer_cortex.bed \
-o macaque_negative_validate_nonEnhancer_500p.bed -l 500
bedtools getfasta -fi $macaqueGene -bed macaque_negative_validate_nonEnhancer_500p.bed > macaque_negative_validate_nonEnhancer_500p.fa

bedtools getfasta -fi $macaqueGene -bed /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/macaqueGC/macaque_putamen_randomGC_10x_validate_500p.bed \
> macaque_putamen_randomGC_10x_validate_500p.fa

cat macaque_negative_validate_nonEnhancer_500p.fa macaque_putamen_randomGC_10x_validate_500p.fa \
> superModel_macaque_negative_validate.fa

# Bat negatives

# negative 3 GC train
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/bat_putamen_randomGC_10x_train_500p.bed
# negative 3 GC validate
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/bat_putamen_randomGC_10x_validate_500p.bed

python $filterPeak --unfilteredPeakFileName batCortex_negative.bed --peakListFileName ratModel_batCortex_negative_train.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val7_batCortex_negative_train.bed

batCortexValidate=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/batCortexNeg/ratModel_val7_batCortex_negative_validate.bed
batCortexTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/ratEvaluate56/batCortexNeg/ratModel_val7_batCortex_negative_train.bed

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/ratToBat/bat_negative_train_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/macaqueToBat/bat_negative_train_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_train_nonEnhancer.bed

cat bat_negative_train_nonEnhancer.bed $batCortexTrain \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_train_nonEnhancer_cortex.bed

python $extendPeak expand_peaks -i bat_negative_train_nonEnhancer_cortex.bed \
-o bat_negative_train_nonEnhancer_500p.bed -l 500

batGene=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic_withMT.fa
bedtools getfasta -fi $batGene -bed bat_negative_train_nonEnhancer_500p.bed > bat_negative_train_nonEnhancer_500p.fa

bedtools getfasta -fi $batGene -bed /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/bat_putamen_randomGC_10x_train_500p.bed \
> bat_putamen_randomGC_10x_train_500p.fa

cat bat_negative_train_nonEnhancer_500p.fa bat_putamen_randomGC_10x_train_500p.fa \
> superModel_bat_negative_train.fa

cat /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/ratToBat/bat_negative_validate_1.bed \
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/macaqueToBat/bat_negative_validate_2.bed \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_validate_nonEnhancer.bed

cat bat_negative_validate_nonEnhancer.bed $batCortexValidate \
| sort -u -k1,1 -k2,2n -k3,3n -k10,10n > bat_negative_validate_nonEnhancer_cortex.bed

python $extendPeak expand_peaks -i bat_negative_validate_nonEnhancer_cortex.bed \
-o bat_negative_validate_nonEnhancer_500p.bed -l 500

bedtools getfasta -fi $batGene -bed bat_negative_validate_nonEnhancer_500p.bed >  bat_negative_validate_nonEnhancer.fa

bedtools getfasta -fi $batGene -bed /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/bat_putamen_randomGC_10x_validate_500p.bed \
> bat_putamen_randomGC_10x_validate_500p.fa

cat bat_negative_validate_nonEnhancer.fa bat_putamen_randomGC_10x_validate_500p.fa \
> superModel_bat_negative_validate.fa


#Final negatives
# Macaque train 24089
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/superModel_macaque_negative_train_500p.bed
# Macaque validate 2671
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/macaqueNegative/superModel_macaque_negative_validate_500p.bed
# Bat train 29532
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/superModel_bat_negative_train_500p.bed
# Bat validate 3491
/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeTrain/batNegative/superModel_bat_negative_validate_500p.bed



# Merge negatives > model


# Additional evaluations
# species specific enhancers. rat/macaque/bat unique enhancers (not in macaque/bat)
# tissue specific enhancers. liver/cortex for all three species. 


batGenom=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic_withMT.fa
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
$bedtools getfasta -fi $batGenom -bed superModel_bat_positive_validate_500p.bed > batPutamenPosValidation.fa
$bedtools getfasta -fi $batGenom -bed superModel_bat_positive_train_500p.bed > batPutamenPostrain.fa


# Motor cortex from bat & macaque.