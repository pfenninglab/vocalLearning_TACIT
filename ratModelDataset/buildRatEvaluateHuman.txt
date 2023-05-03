bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py

# evaluate on First human putamen enhancers
# positive: human enhancer whose rat orthologs are not enhancers
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human1/putamen_human.narrowpeak

# 1 map human to rat
sbatch $mapPeak -i $humanPeak -f Homo_sapiens -t Rattus_norvegicus
# 2 filter rat peaks
ratEnh=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed
$bedtools intersect -a Homo_sapiensMapToRattus_norvegicus_halper.narrowpeak -b $ratEnh -v > humanMapRatNonOCR.bed

# 3 limit to rat validation
while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> humanMapRatNonOCR_validate.bed
fi
done < humanMapRatNonOCR.bed

# 4 get human enhancers of rat orthologs
python $filterPeak --unfilteredPeakFileName $humanPeak \
--peakListFileName humanMapRatNonOCR_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName humanMapRatNonOCR_positive_val.bed

# 5 preprocess
python $extendPeak expand_peaks -i humanMapRatNonOCR_positive_val.bed -o ratModel_evaluate_12_positive_500p.bed -l 500


# negative: human orthologs of rat enhancers that are not enhancers
# 1 map rat to human
ratVal=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human1/rat_pos_validate.narrowpeak
sbatch $mapPeak -i $ratVal -f Rattus_norvegicus -t Homo_sapiens 
# 2 filter peaks
ratMaphuman=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human1/Rattus_norvegicusMapToHomo_sapiens_halper.narrowpeak

humanFullPeak1=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/CaudatePutamen_DNase_out/out/peak/macs2/rep2/Putamen_DNase.nodup.pf.pval0.01.300K.filt.narrowPeak.gz
$bedtools intersect -a Rattus_norvegicusMapToHomo_sapiens_halper.narrowpeak -b $humanFullPeak1 -v > humanMapRatNonOCR_negative_val.bed


# 3 preprocess 
python $extendPeak expand_peaks -i humanMapRatNonOCR_negative_val.bed -o ratModel_evaluate_12_negative_500p.bed -l 500


# validation
srun -p pfen3 -n 1 --gres gpu:1 --mem=6GB --pty bash
conda activate keras2-tf27
python -m scripts.validate -config rat_model_config.yaml -model /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/ratPutamenModel/model1.h5


# Evaluate on second human putamen
pwd=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human2
#-1 preprocess enhancer data
#-1.1 filter < 20kb from the closest protein-coding transcription start site
humanPutamen=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/PUT/cromwell-executions/atac/cee5204e-3e9a-4437-868e-9fc8f05312af/call-reproducibility_idr/execution/optimal_peak.narrowPeak.gz
starts=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanGenome/gencode.v27.annotation.protTranscript.TSSsWithStrand_sorted.bed

$bedtools window -a $humanPutamen -b $starts -v -w 20000 > humanPutamenFilter1.narrowPeak
# 89034
#-1.2 Remove peaks overlap Protein-coding exons
exon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanGenome/gencode.v27.annotation.protCDS_geneNames.bed
$bedtools intersect -a humanPutamenFilter1.narrowPeak -b $exon -v > humanPutamenFilter2.narrowPeak
# 87793

#-1.3 remove super enhancers with size > 1000bp; add peak name
count=0;
while IFS=$'\t' read -r -a array; do
count=$((count+1))
if (( $((${array[2]}-${array[1]})) <= 1000 )); then
array[3]="HSP2_"${array[0]}_$count
echo ${array[@]} | tr " " "\t" >> humanPutamenEnhancer2.narrowPeak 
fi
done < humanPutamenFilter2.narrowPeak 
#80856 

# positive: human enhancer whose rat orthologs are not enhancers

# 1 map human to rat
sbatch $mapPeak -i humanPutamenEnhancer2.narrowPeak -f Homo_sapiens -t Rattus_norvegicus
# 2 filter rat peaks
ratEnh=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratEnhGenB.bed
#40*** -> 33623

# 3 limit to rat validation
while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> humanMapRatNonOCR_validate.bed
fi
done < humanMapRatNonOCR.bed

# 4 get human enhancers of rat orthologs
python $filterPeak --unfilteredPeakFileName humanPutamenEnhancer2.narrowPeak \
--peakListFileName humanMapRatNonOCR_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName humanMapRatNonOCR_positive_val.bed
# -> 2786

# 5 preprocess
python $extendPeak expand_peaks -i humanMapRatNonOCR_positive_val.bed -o ratModel_evaluate_12_positive_500p.bed -l 500

# negative: human orthologs of rat enhancers that are not enhancers

ratMaphuman=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human1/Rattus_norvegicusMapToHomo_sapiens_halper.narrowpeak
humanFullPeak2=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/PUT/cromwell-executions/atac/cee5204e-3e9a-4437-868e-9fc8f05312af/call-macs2_pooled/execution/SRR5367726_1.merged.nodup.tn5.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $ratMaphuman -b $humanFullPeak2 -v > humanMapRatNonOCR_negative_val.bed
python $extendPeak expand_peaks -i humanMapRatNonOCR_negative_val.bed -o ratModel_evaluate_13_negative_500p.bed -l 500


# Evaluation on human cortex enhancers
# Positives: putamen enhancers that overlap these cortex peaks
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/evaluateHuman/human1/putamen_human.narrowpeak
humanCortex=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/FrontalCortexAll_DNase_out/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
$bedtools intersect -a $humanPeak -b $humanCortex > human_PutamenOverlapCortex.bed
# count: 22641
sbatch $mapPeak -i human_PutamenOverlapCortex.bed -f Homo_sapiens -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> human_putamenCortex_mapRat_validate.bed
fi
done < humanMapRatNonOCR.bed

python $filterPeak --unfilteredPeakFileName halper.narrowPeak \
--peakListFileName human_putamenCortex_mapRat_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName human_PutamenOverlapCortex_positive_val.bed

python $extendPeak expand_peaks -i human_PutamenOverlapCortex_positive_val.bed -o human_PutamenOverlapCortex_positive_val_500p.bed -l 500

# Negatives: cortex enhancers that do not overlap any putamen enhancers (including non-reproducible enhancers)
humanFullPeak1=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/CaudatePutamen_DNase_out/out/peak/macs2/rep2/Putamen_DNase.nodup.pf.pval0.01.300K.filt.narrowPeak.gz
$bedtools intersect -a $humanCortex -b $humanFullPeak1 -v > humanCortex_negative.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "human_cortex_"i, $5, $6, $7, $8, $9, $10}//{i++}' humanCortex_negative.bed >> humanCortex_negative_named.bed

sbatch $mapPeak -i humanCortex_negative_named.bed -f Homo_sapiens -t Rattus_norvegicus

halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile humanCortex_negative.bed -tFile Homo_sapiensMapToRattus_norvegicus_halLiftover.narrowpeak \
-sFile Homo_sapiensMapToRattus_norvegicus_summits_halLiftover.narrowpeak \
-oFile humanCortex_negative_halper.narrowpeak -narrowPeak

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> humanCortex_negative_validate.bed
fi
done < 

python $filterPeak --unfilteredPeakFileName $humanCortex \
--peakListFileName humanCortex_negative_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName human_PutamenOverlapCortex_negative_val.bed

python $extendPeak expand_peaks -i human_PutamenOverlapCortex_negative_val.bed -o human_PutamenOverlapCortex_negative_val_500p.bed -l 500


