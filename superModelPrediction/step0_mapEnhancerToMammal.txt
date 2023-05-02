
# clean-up halper results
for i in *sFile.bed.gz; do
    mv $i tmpFiles;
done
for i in *tFile.bed.gz; do
    mv $i tmpFiles;
done

Manis_tricuspis
Carlito_syrichta

sbatch ~/codes/halMap.sh -i rat_enhancer.bed -f Rattus_norvegicus -t Manis_tricuspis

sbatch ~/codes/halMap.sh -i bat_putamen_cactus.bed -f Rousettus_aegyptiacus -t Macaca_mulatta 


for i in *.gz; do
    gunzip $i;
done

# Make species specific enhancers and map to 224 mammals
filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py

python $filterPeak --unfilteredPeakFileName macaque_putamen_enhancer.bed  --peakListFileName Macaca_mulatta_MapTo_Rattus_norvegicus_halper.narrowpeak --unfilteredPeakNameCol 3 \
--outputFileName macaque_filterRat_putamenEnhancer.bed --removePeaks


python $filterPeak --unfilteredPeakFileName bat_putamen_cactus.bed --peakListFileName Rousettus_aegyptiacusMapToRattus_norvegicus_halper.narrowpeak --unfilteredPeakNameCol 3 \
--outputFileName bat_filterRat_putamenEnhancer.bed --removePeaks

python $filterPeak --unfilteredPeakFileName bat_filterRat_putamenEnhancer.bed --peakListFileName Rousettus_aegyptiacus_MapTo_Macaca_mulatta_halper.narrowpeak --unfilteredPeakNameCol 3 \
--outputFileName bat_filterRatMacaque_putamenEnhancer.bed --removePeaks

python $filterPeak --unfilteredPeakFileName  --peakListFileName bat_filterRatMacaque_putamenEnhancer.bed --unfilteredPeakNameCol 3 \
--outputFileName bat_filterRat_putamenEnhancer.bed --removePeaks


convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt

python $convChName --bedFileName macaque_filterRat_putamenEnhancer.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName macaque_filterRat_putamenEnhancer_gb.bed