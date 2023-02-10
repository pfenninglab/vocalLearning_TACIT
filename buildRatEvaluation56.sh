# additional Evaluation datasets
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt

# evaluation 5
# Postives: macaque putamen enhancers that are also liver enhancers
macaqueLiver=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueAtac/Liver/cromwell-executions/atac/1f5fd9f0-d389-4184-99cb-c1125fd7f064/call-reproducibility_idr/execution/optimal_peak_nonCDS_enhancerShort.bed.gz
macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
$bedtools intersect -a $macaquePutamen -b $macaqueLiver -wa -u > macaqueLiver_positive.bed

# map macaque liver peaks to rat

python $convChName --bedFileName macaqueLiver_positive.bed --chromNameDictFileName $genBank \
--chromNameDictReverse  --outputFileName macaqueLiver_positive_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_liver_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueLiver_positive_UCSC.bed >> macaqueLiver_positive_UCSC_named.bed

sbatch $mapPeak -i macaqueLiver_positive_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_positive_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueLiver_positive_UCSC_named.bed  --peakListFileName ratModel_macaqueLiver_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val5_macaqueLiver_positive_validate.bed

python $convChName --bedFileName ratModel_val5_macaqueLiver_positive_validate_500p.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val5_macaqueLiver_positive_validate_500p_a.bed


# Negatives: macaque liver enhancers that are not putamen enhancers
# (make sure to remove all peaks, including non-reproducible peaks)

macaqueAllPeaks=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $macaqueLiver -b $macaqueAllPeaks -v > macaqueLiver_negative.bed

python $convChName --bedFileName macaqueLiver_negative.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName macaqueLiver_negative_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_liver_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueLiver_negative_UCSC.bed >> macaqueLiver_negative_UCSC_named.bed

sbatch $mapPeak -i macaqueLiver_negative_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueLiver_negative_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueLiver_negative_UCSC_named.bed --peakListFileName ratModel_macaqueLiver_negative_validate.bed  --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val5_macaqueLiver_negative_validate.bed

python $convChName --bedFileName ratModel_val5_macaqueLiver_negative_validate_500p.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val5_macaqueLiver_negative_validate_500p_a.bed


python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val5_macaqueLiver_positive_validate.bed -o ratModel_val5_macaqueLiver_positive_validate_500p.bed -l 500
python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val5_macaqueLiver_negative_validate.bed -o ratModel_val5_macaqueLiver_negative_validate_500p.bed -l 500


# evaluation 6
macaqueCortex=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueAtac/OfM/peak/idr_reproducibility/idr.optimal_peak.inM1_nonCDS_enhancerShort.bed

# Postives: macaque putamen enhancers that are also cortex enhancers

macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
$bedtools intersect -a $macaquePutamen -b $macaqueCortex -wa -u > macaqueCortex_positive.bed

python $convChName --bedFileName macaqueCortex_positive.bed --chromNameDictFileName $genBank \
--chromNameDictReverse  --outputFileName macaqueCortex_positive_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_Cortex_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueCortex_positive_UCSC.bed >> macaqueCortex_positive_UCSC_named.bed

sbatch $mapPeak -i macaqueCortex_positive_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_positive_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueCortex_positive_UCSC_named.bed  --peakListFileName ratModel_macaqueCortex_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val6_macaqueCortex_positive_validate.bed

python $convChName --bedFileName ratModel_val6_macaqueCortex_positive_validate.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val6_macaqueCortex_positive_validate_converted.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val6_macaqueCortex_positive_validate_converted.bed -o ratModel_val6_macaqueCortex_positive_validate_500p.bed -l 500

# Negatives: macaque cortex enhancers that are not putamen enhancers

macaqueAllPeaks=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $macaqueCortex -b $macaqueAllPeaks -v > macaqueCortex_negative.bed

python $convChName --bedFileName macaqueCortex_negative.bed --chromNameDictFileName $genBank \
--chromNameDictReverse  --outputFileName macaqueCortex_negative_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_Cortex_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueCortex_negative_UCSC.bed >> macaqueCortex_negative_UCSC_named.bed

sbatch $mapPeak -i macaqueCortex_negative_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueCortex_negative_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueCortex_negative_UCSC_named.bed  --peakListFileName ratModel_macaqueCortex_negative_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val6_macaqueCortex_negative_validate.bed

python $convChName --bedFileName ratModel_val6_macaqueCortex_negative_validate.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val6_macaqueCortex_negative_validate_converted.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val6_macaqueCortex_negative_validate_converted.bed -o ratModel_val6_macaqueCortex_negative_validate_500p.bed -l 500

# Evaluate with model

find wandb/ -wholename *6sj134kn*/files/model-latest.h5

model1=wandb/run-20220829_013123-6sj134kn/files/model-latest.h5

srun -p pfen3 -n 1 --gres gpu:1 --mem=6GB --pty bash
conda activate keras2-tf27
python -m scripts.validate -config rat_model_config.yaml -model /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/ratPutamenModel/model-latest.h5
python -m scripts.validate -config rat_model_config.yaml -model /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/ratPutamenModel/model2.h5

# Evaluate 7 bat

batCortex=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatAtac/OfMBat1K/call-reproducibility_idr/execution/idr.optimal_peak.inM1_nonCDS_enhancerShort.bed.gz
batPutamen=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-reproducibility_idr/execution/idr.optimal_peak.narrowPeak.gz

$bedtools intersect -a $batPutamen -b $batCortex -wa -u > batCortex_positive.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "bat_Cortex_"i, $5, $6, $7, $8, $9, $10}//{i++}' batCortex_positive.bed >> batCortex_positive_named.bed

#liftover to bat1k
seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName batCortex_positive_named.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName batCortex_positive_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' batCortex_positive_Seqname.bed > batCortex_positive_Seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
liftOver=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/liftOver
$liftOver batCortex_positive_Seqname_int.bed $chainFile bat_cortex_lifted.bed bat_cortex_unlifted.bed
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_cortex_lifted.bed > bat_cortex_lifted_genbank.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName bat_cortex_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_cortex_cacform.bed

sbatch $mapPeak -i bat_cortex_cacform.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_positive_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName batCortex_positive_named.bed  --peakListFileName ratModel_batCortex_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val7_batCortex_positive_validate.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val7_batCortex_positive_validate.bed -o ratModel_val7_batCortex_positive_validate_500bp.bed -l 500

# negatives: cortex enhancers that are not putamen enhancers

batAllPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $batCortex -b $batAllPeak -v > batCortex_negative.bed

#liftover to bat1k
seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName batCortex_negative.bed --chromNameDictFileName $seqName \
--chromNameDictReverse  --outputFileName batCortex_negative_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' batCortex_negative_Seqname.bed > batCortex_negative_Seqname_int.bed

$liftOver batCortex_negative_Seqname_int.bed $chainFile bat_cortex_lifted.bed bat_cortex_unlifted.bed
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_cortex_lifted.bed > bat_cortex_lifted_genbank.bed
python $convChName --bedFileName bat_cortex_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_cortex_cacform.bed

sbatch $mapPeak -i bat_cortex_cacform.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_batCortex_negative_train.bed
fi
done < Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName batCortex_negative.bed --peakListFileName ratModel_batCortex_negative_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val7_batCortex_negative_validate.bed

python /home/tianyul3/codes/repo/mouse_sst/preprocessing.py expand_peaks -i ratModel_val7_batCortex_negative_validate.bed -o ratModel_val7_batCortex_negative_validate_500bp.bed -l 500





batGenome=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic_withMT.fa


# Evaluation on macaque nucleus accumbens

#positive
macaqueAccumben=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueAtac/NAcc_optimal_peak_enhancerShort.bed

macaquePutamen=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz
$bedtools intersect -a $macaquePutamen -b $macaqueAccumben -wa -u > macaqueAccumben_positive.bed

python $convChName --bedFileName macaqueAccumben_positive.bed --chromNameDictFileName $genBank \
--chromNameDictReverse  --outputFileName macaqueAccumben_positive_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_accumben_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueAccumben_positive_UCSC.bed >> macaqueAccumben_positive_UCSC_named.bed

sbatch $mapPeak -i macaqueAccumben_positive_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_positive_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_positive_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_positive_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueAccumben_positive_UCSC_named.bed  --peakListFileName ratModel_macaqueAccumben_positive_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val5_macaqueAccumben_positive_validate.bed

python $convChName --bedFileName ratModel_val5_macaqueAccumben_positive_validate_500p.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val5_macaqueAccumben_positive_validate_500p_a.bed

#  negative
macaqueAllPeaks=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz
$bedtools intersect -a $macaqueAccumben -b $macaqueAllPeaks -v > macaqueAccumben_negative.bed

python $convChName --bedFileName macaqueAccumben_negative.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName macaqueAccumben_negative_UCSC.bed

awk 'BEGIN{OFS="\t"; i=1}{print $1, $2, $3, "macaque_Accumben_"i, $5, $6, $7, $8, $9, $10}//{i++}' macaqueAccumben_negative_UCSC.bed >> macaqueAccumben_negative_UCSC_named.bed

sbatch $mapPeak -i macaqueAccumben_negative_UCSC_named.bed -f Macaca_mulatta -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_negative_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_negative_validate.bed
else
echo ${array[@]} | tr " " "\t" >> ratModel_macaqueAccumben_negative_train.bed
fi
done < Macaca_mulattaMapToRattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaqueAccumben_negative_UCSC_named.bed --peakListFileName ratModel_macaqueAccumben_negative_validate.bed  --unfilteredPeakNameCol 3 \
--outputFileName ratModel_val5_macaqueAccumben_negative_validate.bed

python $convChName --bedFileName ratModel_val5_macaqueAccumben_negative_validate_500p.bed --chromNameDictFileName $genBank \
--outputFileName ratModel_val5_macaqueAccumben_negative_validate_500p_a.bed

