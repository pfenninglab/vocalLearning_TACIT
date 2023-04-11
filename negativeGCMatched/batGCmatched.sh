# create background directory
bgdir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/batbg
bat1k=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/genome/GCF_014176215.1_mRouAeg1.p_genomic_withMT.fa
sbatch -p pool1 --mem=10G create_background_repository.sh -f $bat1k -s 500 -r $bgdir

batPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-call_peak_pooled/execution/rep.pooled.pval0.01.300K.bfilt.narrowPeak.gz
batExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.CDS.geneNames.bed
batTss=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.transcriptAndHumanLiftover.geneNames_TSSWithStrand_sorted.bed

bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
$bedtools window -a  bat_train.bed -b $batTss -v -w 20000 | 
$bedtools intersect -a stdin -b $batExon -v |
$bedtools intersect -a stdin -b $batPeak > train_tmp.bed

batGenom=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic_withMT.fa
batEnhancer=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/batPositive/bat_enhancer_named.bed

extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py

python $extendPeak expand_peaks -i $batEnhancer \
-o bat_putamen_enhancer_500p.bed -l 500

bedtools getfasta -fi $batGenom -bed bat_putamen_enhancer_500p.bed > bat_putamen_enhancer.fa
# RUN biasaway

sbatch -p pool1 -t 1-00:00:00 --mem=20G biasaway c --foreground bat_putamen_enhancer.fa --nfold 10 --deviation 2.6 --step 50 --seed 1 --winlen 100 \
--bgdirectory /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/negativeGCmatched/bat/batbg > bat_putamen_enhancer_10x_window.fa




grep -e ">" bat_putamen_enhancer_10x.fa > bat_putamen_enhancer_10x_header.txt
python generateBedFromFa.py bat_putamen_enhancer_10x_header.txt bat_putamen_enhancer_10x.bed

# filter peaks
bedtools window -a  bat_putamen_enhancer_10x.bed -b $batTss -v -w 20000 | 
bedtools intersect -a stdin -b $batExon -v |
bedtools intersect -a stdin -b $batPeak | sort -u -k1,1 -k2,2n -k3,3n > bat_putamen_enhancer_10x_filtered.bed
# 35678

seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
python $convChName --bedFileName bat_putamen_enhancer_10x_filtered.bed --chromNameDictFileName $seqName \
--chromNameDictReverse --outputFileName bat_enhancer_Seqname.bed
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' bat_enhancer_Seqname.bed > bat_enhancer_Seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
liftOver bat_enhancer_Seqname_int.bed $chainFile bat_putamen_lifted.bed bat_putamen_unlifted.bed
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' bat_putamen_lifted.bed > bat_putamen_lifted_genbank.bed
python $convChName --bedFileName bat_putamen_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName bat_putamen_random10x_cactus.bed

mapPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/mapPeaks/mapPeak.sh
sbatch -t 1-00:00:00 $mapPeak -i bat_putamen_random10x_cactus.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

sbatch -t 1-00:00:00 ~/codes/mapPeakNosummit.sh  -i bat_putamen_random10x_cactus.bed -f Rousettus_aegyptiacus -t Rattus_norvegicus

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> batMapRat_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> batMapRat_validate.bed
else
echo ${array[@]} | tr " " "\t" >> batMapRat_train.bed
fi
done < Rousettus_aegyptiacus_MapTo_Rattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName bat_putamen_enhancer_10x_filtered.bed --peakListFileName batMapRat_train.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_putamen_randomGC_10x_train.bed

python $extendPeak expand_peaks -i bat_putamen_randomGC_10x_train.bed \
-o bat_putamen_randomGC_10x_train_500p.bed -l 500 -c endpoints

python $filterPeak --unfilteredPeakFileName bat_putamen_enhancer_10x_filtered.bed --peakListFileName batMapRat_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_putamen_randomGC_10x_validate.bed

python $extendPeak expand_peaks -i bat_putamen_randomGC_10x_validate.bed \
-o bat_putamen_randomGC_10x_validate_500p.bed -l 500 -c endpoints



awk 'BEGIN{OFS="\t"}{print $1, ((($2+$3)/2)), $3, $4}' bat_putamen_random10x_cactus.bed | \
awk 'BEGIN{OFS="\t"}{print $1, $2, $2+1, $4}' > tmp.bed

# summit at center since summit is not provided here.
while IFS=$'\t' read -r -a array; do
v1=$(((${array[1]}+${array[2]})/2));
v2=$((${v1}+1));
array[1]=$v1;
array[2]=$v2;
echo ${array[@]} | tr " " "\t" >> tmp.bed
done < t1.bed