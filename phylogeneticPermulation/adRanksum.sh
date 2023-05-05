#!/bin/bash
#SBATCH --partition=pool1
#SBATCH --job-name=ad
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/log/AD_err_%A.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/log/AD_%A.txt

humanBed=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap/Homo_sapiens.enhancerMapped.bed
humanTSS=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/HumanGenome/gencode.v27.annotation.protTranscript.TSSsWithStrand_sorted.bed

alz1=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/adGenes.ros.amyloid_sqrt_adjp0.01.txt
alz2=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/adGenes.ros.pathoAD_adjp0.01.txt
alz3=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/adGenes.ros.pmAD_adjp0.01.txt 
alz4=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/GeneLists/adGenes.ros.tangles_sqrt_adjp0.01.txt

perm1m=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/longevity_perm1m_parsed.csv 
out=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/longevity/ranksum/ad
script=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/pValShiftTest.sh 

outputFile=${out}/ADresult.txt
echo "AD 1 " >> ${outputFile}
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $alz1 -n alz1 -r >> ${outputFile}
echo "AD 2 " >> ${outputFile}
sh $script -i $perm1m -b $mouseBed -t $mouseTss -o $out -g $alz2 -n alz2 -r >> ${outputFile}
echo "AD 3 " >> ${outputFile}
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $alz3 -n alz3 -r >> ${outputFile}
echo "AD 4 " >> ${outputFile}
sh $script -i $perm1m -b $humanBed -t $humanTSS -o $out -g $alz4 -n alz4 -r >> ${outputFile}
