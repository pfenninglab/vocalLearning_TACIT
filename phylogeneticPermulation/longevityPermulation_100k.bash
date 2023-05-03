#!/bin/bash
#SBATCH -p pool1
#SBATCH --job-name=perm100k
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/log/perm3_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/log/perm3_%A_%a.txt
#SBATCH --mem=4G
#SBATCH --time=72:00:00
#SBATCH --array=1-50
source ~/.bashrc
conda activate hal

seed=`od --read-bytes=4 --address-radix=n --format=u4 /dev/random | awk '$1>=2^31{$1-=2^32}1'`
data="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity"
tree="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/Zoonomia_ChrX_lessGC40_241species_30Consensus.tree"
preds="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/permulation_100k_predictionMatrix.csv"
species="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/species.txt"
traits="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/LQ_ZoonomiaBoreoeutheria.txt"
out="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/permul3/longevity_perm_100k_result.csv"
perm="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/analysis/perm10k/perm100k.csv"

Rscript /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/TACIT/ocr_phylolm_conditional.r \
$tree $preds $species $traits $out ${SLURM_ARRAY_TASK_ID} 50 \
$perm $seed Longevity 