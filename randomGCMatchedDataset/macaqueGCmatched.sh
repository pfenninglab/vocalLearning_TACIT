# Notes for installing packages
BiocManager::install(c('GenomicRanges','rtracklayer','BSgenome'), dependencies = TRUE)


install.packages(c('ROCR','kernlab','seqinr'), repos='https://cloud.r-project.org', dependencies = TRUE)

BiocManager::install('BSgenome', INSTALL_opts = '--no-lock')
# Generate first 4 columns for bed
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, $4}' superModel_macaque_positive_train_500p_n.bed > superModel_macaque_positive_train_500p_4c.bed
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, $4}' superModel_macaque_positive_validate_500p_n.bed > superModel_macaque_positive_validate_500p_4c.bed


awk 'BEGIN{OFS="\t"}{print $1, $2, $3, $4}' macaquePutamen.bed > macaquePutamen_4c.bed

# install masked genom
install.packages("/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/BSgenome.Mmulatta.UCSC.rheMac8.masked.full", repos=NULL, type="source")
library("BSgenome.Mmulatta.UCSC.rheMac8.masked.full")

# Create masked library
library("BSgenome")
library("BSgenome.Mmulatta.UCSC.rheMac8")
forgeMaskedBSgenomeDataPkg("/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/rheMac8SeedFile.txt")
library("BSgenome.Mmulatta.UCSC.rheMac8.masked.full")

# R script
library("gkmSVM")
library("BSgenome.Rnorvegicus.UCSC.rn6.masked.full")
GCRepMatch <- genNullSeqs("
	/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/data/ratModelDataset/rat_pos_total_4col.bed
	", outputBedFN="/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/data/ratModelDataset/rat_total_randomGCRepeatMatched_10x.bed", xfold=10, length_match_tol=0.00, nMaxTrials=100, genome=BSgenome.Rnorvegicus.UCSC.rn6.masked.full)

install.packages("/ocean/projects/bio200034p/tianyul3/vocallearningTACIT/putamen/putamenSupermodel/randomGC/BSgenome.Mmulatta.UCSC.rheMac8.masked.full/", repos=NULL, type="source")

awk '{split($0,a,"_"); print a[1], a[2], a[3], a[4]a[5]}' negativeCoordinate.txt|
awk -v OFS='\t' '{ print $1, $2, $3, $4}' > tmp.bed



bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
macaqueTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic_andhg38.transcript.geneNames_TSSWithStrand_sorted_UCSCNames.bed
macaqueExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic.protCDS_geneNames_UCSCNames.bed
macaqueFull=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/pooled-rep/basename_prefix.pooled.pval0.01.300K.bfilt.narrowPeak.gz

# Biasaway for macaque
# Create background directory from background sequence
macaque8=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/rheMac8.fa
outdir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/repo/macaquebgdir
sbatch -p pool1 -o macbgdir.out --mem=10G create_background_repository.sh -f $macaque8 -s 500 -r $outdir
# Get fasta from enhancer peaks
macaquePeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaquePutamen_500p.bed
macaqueGene=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/rheMac8.fa
bedtools getfasta -fi $macaqueGene -bed $macaquePeak > macaque_putamen_enhancer.fa
# Biasaway for random GC-matched
sbatch -p pool1 --mem=20G biasaway g -f macaque_putamen_enhancer.fa \
-r /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/repo/macaquebgdir \
-n 10 -l > macaque_putamen_enhancer_10x.fa
# Biasawat with sliding window
sbatch -p pool1 --mem=20G biasaway c --foreground macaque_putamen_enhancer.fa --nfold 10 --deviation 2.6 --step 50 --seed 1 --winlen 100 \
--bgdirectory /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/repo/macaquebgdir > macaque_putamen_enhancer_10x_window.fa

# Recreate bed files from fasta headers
grep -e ">" macaque_putamen_enhancer_10x.fa > macaque_10x_header.txt 
python generateBedFromFa.py macaque_10x_header.txt macaque_putamen_10x.bed
# REMOVE EXON TSS 
bedtools window -a macaque_10x.bed -b $macaqueTSS -v -w 20000 | 
bedtools intersect -a stdin -b $macaqueExon -v |
bedtools intersect -a stdin -b $macaqueFull | sort -u -k1,1 -k2,2n -k3,3n > macaque_putamen_randomGC_10x_filtered.bed

# Convert to Cactus alignment chromosome format
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
python $convChName --bedFileName macaque_putamen_randomGC_10x_filtered.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName macaque_putamen_randomGC_10x_genBank.bed
# Map to Rat
sbatch -t 1-00:00:00 ~/codes/mapPeak.sh -i macaque_putamen_randomGC_10x_genBank.bed -f Macaca_mulatta -t Rattus_norvegicus

sbatch -t 1-00:00:00 ~/codes/mapPeakNosummit.sh -i macaque_putamen_randomGC_10x_genBank.bed -f Macaca_mulatta -t Rattus_norvegicus

extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py

while IFS=$'\t' read -r -a array; do
if [ "${array[0]}" = "chr3" ] || [ "${array[0]}" = "chr5" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_test.bed
elif [ "${array[0]}" = "chr8" ] || [ "${array[0]}" = "chr16" ]; then
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_validate.bed
else
echo ${array[@]} | tr " " "\t" >> macaqueMapRat_train.bed
fi
done < Macaca_mulatta_MapTo_Rattus_norvegicus_halper.narrowpeak

python $filterPeak --unfilteredPeakFileName macaque_putamen_randomGC_10x_genBank.bed --peakListFileName macaqueMapRat_train.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_putamen_randomGC_10x_train.bed
python $convChName --bedFileName macaque_putamen_randomGC_10x_train.bed --chromNameDictFileName $genBank \
--outputFileName macaque_putamen_randomGC_10x_train_c.bed
python $extendPeak expand_peaks -i macaque_putamen_randomGC_10x_train_c.bed \
-o macaque_putamen_randomGC_10x_train_500p.bed -l 500 -c endpoints

python $filterPeak --unfilteredPeakFileName macaque_putamen_randomGC_10x_genBank.bed --peakListFileName macaqueMapRat_validate.bed --unfilteredPeakNameCol 3 \
--outputFileName macaque_putamen_randomGC_10x_validate.bed
python $convChName --bedFileName macaque_putamen_randomGC_10x_validate.bed --chromNameDictFileName $genBank \
--outputFileName macaque_putamen_randomGC_10x_validate_c.bed
python $extendPeak expand_peaks -i macaque_putamen_randomGC_10x_validate_c.bed \
-o macaque_putamen_randomGC_10x_validate_500p.bed -l 500 -c endpoints

