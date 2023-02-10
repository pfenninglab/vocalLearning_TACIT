#Build negative sets: non-OCR ortholog from rat, macaque, bat

cd /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen

# Rat/mouse no conversion of chromosome format; Rename peak names for rat
# map rat enhancers to human

wd=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData
cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal

# 1 halliftover rat peaks
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover \
--bedType 4 /data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal \
Rattus_norvegicus ${wd}/ratEnhGenB.bed \
Homo_sapiens ${wd}/ratMapHuman_halliftover.bed

# 2 halliftover rat summits
awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}' ${wd}/ratEnhGenB.bed > ${wd}/ratMapHuman_Peaks_summits.bed
echo "finished summit file"
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover --bedType 4 $cacAlign \
Rattus_norvegicus ${wd}/ratMapHuman_Peaks_summits.bed \
Homo_sapiens ${wd}/ratMapHuman_summits_halLiftover.bed

# 3 HALPER 
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile ${wd}/ratEnhGenB.bed -tFile ${wd}/ratMapHuman_halliftover.bed -sFile ${wd}/ratMapHuman_summits_halLiftover.bed \
-oFile ${wd}/ranMapHuman_Min50Max1000Protect5_HALPER_.bed -narrowPeak

# 4 remove human peaks
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/CaudatePutamen_DNase_out/out/peak/macs2/rep2/Putamen_DNase.nodup.pf.pval0.01.300K.filt.narrowPeak.gz
ratPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ranMapHuman_Min50Max1000Protect5_HALPER_.bed
./bedtools intersect -a $ratPeak -b $humanPeak -v > ${wd}/ratMapHuman_Halper_filter.bed

# 5 rename peak names for rat --> todo
awk 'BEGIN{OFS="\t"}{print $1, $2, $3, "rat_"$4, $5, $6, $7, $8, $9, $10}' ${wd}/ratMapHuman_Halper_filter.bed > ${wd}/ratMapHuman_Halper_final.bed







# map macaque (Macaca_mulatta) to human

macqTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic_andhg38.transcript.geneNames_TSSWithStrand_sorted_UCSCNames.bed
macqExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GCF_000772875.2_Mmul_8.0.1_genomic.protCDS_geneNames_UCSCNames.bed
macqPeak=/projects/MPRA/Irene/macaque/atac-pipeline-output/StrP/peak/idr_reproducibility/idr.optimal_peak.narrowPeak.gz

# 1 filter peaks to get enhancers; rename peaks
./bedtools window -a $macqPeak -b $macqTSS -v -w 20000 > ${wd}/macaque_filter1.bed
./bedtools intersect -a ${wd}/macaque_filter1.bed -b $macqExon -v > ${wd}/macaque_filter2.bed
count=0;
while IFS=$'\t' read -r -a array; do
count=$((count+1))
if (( $((${array[2]}-${array[1]})) > 1000 )); then
continue
else
array[3]="MACQ_"${array[0]}_$count
echo ${array[@]} | tr " " "\t" >> ${wd}/macaque_fil.bed
fi
done < ${wd}/macaque_filter2.bed

# 2 convert chromosome name to GenBank format
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
genBank=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MacaqueGenome/GenbankNameToChromNameRheMac8.txt
python $convChName --bedFileName ${wd}/macaque_fil.bed --chromNameDictFileName $genBank \
--chromNameDictReverse --outputFileName ${wd}/maca_Enhancer_GenB.bed

# 3 Map Macaque peaks to human 
cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover --bedType 4 $cacAlign \
Macaca_mulatta ${wd}/maca_Enhancer_GenB.bed \
Homo_sapiens ${wd}/macaque_MapHuman_halliftover.bed

awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}' ${wd}/maca_Enhancer_GenB.bed > ${wd}/macMapHuman_Peaks_summits.bed
echo "finished summit file"
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover --bedType 4 $cacAlign \
Macaca_mulatta ${wd}/macMapHuman_Peaks_summits.bed \
Homo_sapiens ${wd}/macaque_MapHuman_summits_halLiftover.bed

halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile ${wd}/maca_Enhancer_GenB.bed -tFile ${wd}/macaque_MapHuman_halliftover.bed -sFile ${wd}/macaque_MapHuman_summits_halLiftover.bed \
-oFile ${wd}/macaque_MapHuman_Min50Max1000Protect5_HALPER_.bed -narrowPeak

# 4 Filter Human peaks
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/CaudatePutamen_DNase_out/out/peak/macs2/rep2/Putamen_DNase.nodup.pf.pval0.01.300K.filt.narrowPeak.gz
./bedtools intersect -a ${wd}/macaque_MapHuman_Min50Max1000Protect5_HALPER_.bed -b $humanPeak -v > ${wd}/macaque_MapHuman_Halper_final.bed









# Rousettus_aegyptiacus

# 1 filter peaks
batPeak=/projects/MPRA/Simone/Bats/StrP/atac_out/atac/878a0bdd-f8e2-47c5-ac19-a8d89973ae7e/call-reproducibility_idr/execution/idr.optimal_peak.narrowPeak.gz
batTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.transcriptAndHumanLiftover.geneNames_TSSWithStrand_sorted.bed
batExon=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/GCF_014176215.1_mRouAeg1.p_genomic.CDS.geneNames.bed

./bedtools window -a $batPeak -b $batTSS -v -w 20000 > ${wd}/bat_filter1.bed
./bedtools intersect -a ${wd}/bat_filter1.bed -b $batExon -v > ${wd}/bat_filter2.bed
count=0;
while IFS=$'\t' read -r -a array; do
count=$((count+1))
if (( $((${array[2]}-${array[1]})) > 1000 )); then
continue
else
array[3]="MACQ_"${array[0]}_$count
echo ${array[@]} | tr " " "\t" >> ${wd}/bat_fil.bed
fi
done < ${wd}/bat_filter2.bed


# Convert to sequence_name convension
seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
python $convChName --bedFileName ${wd}/bat_fil.bed --chromNameDictFileName $seqName \
--chromNameDictReverse --outputFileName ${wd}/bat_seqname.bed

# 2 liftOver chain from Bat1K Egyptian fruit bat assembly to Egyptian fruit bat assembly in Cactus
# Convert to integers to fit Liftover
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' ${wd}/bat_seqname.bed > ${wd}/bat_seqname_int.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
./liftOver ${wd}/bat_seqname_int.bed $chainFile ${wd}/bat_lifted.bed ${wd}/bat_unlifted.bed



# Convert chromoname to genBank format
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' ${wd}/bat_lifted.bed > ${wd}/bat_lifted_genbank.bed 
# conver chromoname to Cactus format
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName ${wd}/bat_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName ${wd}/bat_cacform.bed

# 3 map from bat to human
cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover --bedType 4 $cacAlign \
Rousettus_aegyptiacus ${wd}/bat_cacform.bed \
Homo_sapiens ${wd}/bat_MapHuman_halliftover.bed

# handle summits here 
awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}' ${wd}/bat_seqname_int.bed > ${wd}/bat_Peaks_summits.bed
chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
./liftOver ${wd}/bat_Peaks_summits.bed $chainFile ${wd}/bat_summit_lifted.bed ${wd}/bat_summit_unlifted.bed
awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4}' ${wd}/bat_summit_lifted.bed > ${wd}/bat_summit_genbank.bed 
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt
python $convChName --bedFileName ${wd}/bat_summit_genbank.bed --chromNameDictFileName $batCactusFormat \
--chromNameDictReverse --outputFileName ${wd}/bat_summit_cacform.bed

cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal
/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover --bedType 4 $cacAlign \
Rousettus_aegyptiacus ${wd}/bat_summit_cacform.bed \
Homo_sapiens ${wd}/bat_summit_halliftover.bed

# HALPER peak + summit (bat)
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py
python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile ${wd}/bat_cacform.bed -tFile ${wd}/bat_MapHuman_halliftover.bed -sFile ${wd}/bat_summit_halliftover.bed \
-oFile ${wd}/bat_MapHuman_Min50Max1000Protect5_HALPER_.bed  -narrowPeak

# 4 Filter Human peaks
humanPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanDNase/CaudatePutamen_DNase_out/out/peak/macs2/rep2/Putamen_DNase.nodup.pf.pval0.01.300K.filt.narrowPeak.gz
./bedtools intersect -a ${wd}/bat_MapHuman_Min50Max1000Protect5_HALPER_.bed -b $humanPeak -v > ${wd}/bat_MapHuman_Halper_final.bed


# Merge three species non-OCR ortholog with sort unique to form the negative sets
cat *_final.bed >> negative_all.bed
sort -u -k1,1 -k2,2n -k3,3n -k10,10n negative_all.bed > negative_set.bed

