# additional Evaluation datasets
# Putamen specific enhancers 

halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt

# evaluation 9

# Postives: rat putamen enhancers that are not motor cortex
ratPutamen=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed
ratCortex=/projects/MPRA/Irene/rats/atac-pipeline-output/M1/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $ratPutamen -b $ratCortex -v > ratModel_evaluate_9_positive.bed

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_evaluate_9_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_evaluate_9_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_evaluate_9_positive_train.bed
fi
done <  ratModel_evaluate_9_positive.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i  ratModel_evaluate_9_positive_validate.bed -o ratModel_evaluate_9_positive_500p.bed -l 500

# Negatives: rat motor cortex specific enhancers
eval9neg=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/additionalEvaluate/ratModel_evaluate_3_negative_validationC_500p.bed



# Evaluation 10

# positives: macaque putamen enhancers that are not motor cortex 

macaC1=/projects/MPRA/Irene/macaque/atac-pipeline-output/OfM/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz 
macaC2=/projects/MPRA/Irene/macaque/atac-pipeline-output/M1/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz

zcat $macaC1 $macaC2 >> /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/macaquePutamenAllPeak.narrowPeak.gz

macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
macaqueCortex=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/macaquePutamenAllPeak.narrowPeak.gz
$bedtools intersect -a $macaquePutamen -b $macaqueCortex -v > macaquePutamen_positive.bed

# map macaque liver peaks to rat

python $convChName --bedFileName macaquePutamen_positive.bed --chromNameDictFileName $genBank \
--chromNameDictReverse  --outputFileName macaquePutamen_positive_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_putamen_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaquePutamen_positive_UCSC.bed >> macaquePutamen_positive_UCSC_named.bed

sbatch $mapPeak -i macaquePutamen_positive_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaquePutamen_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaquePutamen_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaquePutamen_positive_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaquePutamen_positive_UCSC_named.bed  --peakListFileName ratModel_macaquePutamen_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val10_macaquePutamen_positive_validate.bed

python $convChName --bedFileName  ratModel_val10_macaquePutamen_positive_validate.bed --chromNameDictFileName $genBank \
--outputFileName  ratModel_val10_macaquePutamen_positive_validate_gb.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val10_macaquePutamen_positive_validate_gb.bed -o ratModel_evaluate_10_positive_500p.bed -l 500

# negatives: macaque motor cortex specific enhancers



#Evaluation 11
# positive: bat putamen enhancers that are not motor cortex

batC1=/projects/MPRA/Simone/Bats/ofM1/atac_out/atac/6ac76aca-6f07-4ca4-8bfd-454c9c57e030/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz 
batC2=/projects/MPRA/Simone/Bats/wM1/atac_out/atac/73b7ca4e-6983-4ddd-adbb-f58586e205a4/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz

zcat $batC1 $batC2 >> /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/batPutamenAllPeak.narrowPeak.gz

batCortex=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/batPutamenAllPeak.narrowPeak.gz
batPutamen=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-reproducibility_idr/execution/idr.optimal_peak.narrowPeak.gz
$bedtools intersect -a $batPutamen -b $batCortex -v > batPutamen_positive.bed

#liftover to bat1k
awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "bat_putamen_"i, $5, $6, $7, $8, $9, $10}//{i++}' batPutamen_positive.bed >> batPutamen_positive_named.bed

seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName batPutamen_positive_named.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName batPutamen_positive_Seqname.bed

awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' batPutamen_positive_Seqname.bed > batPutamen_positive_Seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
liftOver=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/liftOver
$liftOver batPutamen_positive_Seqname_int.bed $chainFile bat_putamen_lifted.bed bat_putamen_unlifted.bed
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_putamen_lifted.bed > bat_putamen_lifted_genbank.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName bat_putamen_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_putamen_cacform.bed

sbatch $mapPeak -i bat_putamen_cacform.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batPutamen_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batPutamen_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_batPutamen_positive_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName batPutamen_positive_named.bed  --peakListFileName ratModel_batPutamen_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val11_batPutamen_positive_validate.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val11_batPutamen_positive_validate.bed -o ratModel_evaluate_11_batPutamen_positive_validate_500bp.bed -l 500

# negative: bat motor cortez specific enhancers

srun -p pfen3 -n 1 --gres gpu:1 --mem=6GB --pty bash
conda activate keras2-tf27
python -m scripts.validate -config rat_model_config.yaml -model /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/ratPutamenModel/model1.h5
python -m scripts.validate -config rat_model_config.yaml -model /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/ratPutamenModel/model2.h5
