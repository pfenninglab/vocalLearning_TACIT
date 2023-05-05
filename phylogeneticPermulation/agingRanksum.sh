#!/bin/bash
#SBATCH --partition=pool1
#SBATCH --job-name=aging
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/log/aging_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/log/aging_%A_%a.txt

humanBed=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap/Homo_sapiens.enhancerMapped.bed
humanTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanGenome/gencode.v27.annotation.protTranscript.TSSsWithStrand_sorted.bed

mouseTss=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MouseGenome/gencode.vM15.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed
mouseBed=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap/Mus_musculus.enhancerMapped.bed

aging1=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/aging.cm_adjp0.01.txt
aging2=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/aging.pe_adjp0.01.txt
aging3=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/aging.ros_adjp0.01.txt
aging4=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/RNASeq/Zhang2021Data/AgingGenes_Brain_Non-Myeloid.neuron.txt
    
perm1m=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/longevity_perm1m_parsed.csv 
out=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/aging
script=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/pValShiftTest.sh 

echo "human aging1 " >> ${out}/aging_result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $aging1 -n aging1 -r >> ${out}/aging_result.txt
echo "human aging 2 " >> ${out}/aging_result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $aging2 -n aging2 -r >> ${out}/aging_result.txt
echo "human aging 3 " >> ${out}/aging_result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $aging3 -n aging3 -r >> ${out}/aging_result.txt
echo "mouse aging 4" >> ${out}/aging_result.txt
sh $script -i $perm1m -b $mouseBed -t $mouseTss -o $out -g $aging4 -n aging4 -r >> ${out}/aging_result.txt


