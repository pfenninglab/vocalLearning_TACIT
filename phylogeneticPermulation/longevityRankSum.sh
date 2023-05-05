#!/bin/bash
#SBATCH --partition=pool1
#SBATCH --job-name=longevity
#SBATCH --cpus-per-task=1

humanBed=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap/Homo_sapiens.enhancerMapped.bed
humanTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanGenome/gencode.v27.annotation.protTranscript.TSSsWithStrand_sorted.bed

mouseTss=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/MouseGenome/gencode.vM15.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed
mouseBed=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap/Mus_musculus.enhancerMapped.bed

longevity1=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/analysis/longevityTrait/brainLongevity.txt
longevity2=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/analysis/longevityTrait/longevity_gene_2.txt
longevity3=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/analysis/longevityTrait/longevity_gene_data5.txt
longevity4=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/analysis/longevityTrait/longevity_gene_data6.txt
            
perm1m=
out=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum
script=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/pValShiftTest.sh 

echo "human longevity 1 " >> ${out}/result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $longevity1 -n longevity1 >> ${out}/result.txt
echo "mouse longevity 2 " >> ${out}/result.txt
sh $script -i $perm1m -b $mouseBed -t $mouseTss -o $out -g $longevity2 -n longevity2 >> ${out}/result.txt
echo "human longevity data 5 " >> ${out}/result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $longevity3 -n longevity3 >> ${out}/result.txt
echo "human longevity data 6 " >> ${out}/result.txt
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $longevity4 -n longevity4 >> ${out}/result.txt
