#!/bin/bash
#SBATCH -p pool1
#SBATCH --job-name=perm1k
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm100k87_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm100k87_%A_%a.txt
#SBATCH --mem=8G
#SBATCH --time=72:00:00
#SBATCH --array=87,1187,2187
source ~/.bashrc
conda activate hal

seed=`od --read-bytes=4 --address-radix=n --format=u4 /dev/random | awk '$1>=2^31{$1-=2^32}1'`
data="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep"
tree="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_ChrX_lessGC40_241species_30Consensus.tree"
preds="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm10k_predictionMatrix.tsv"
species="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/species.txt"
traits="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_phenotypes_12-14-21.csv"
out="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/perm10k/sleep_perm_10k.csv"
perm="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm10k_peakList.csv"

Rscript /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/TACIT/ocr_phylolm_conditional.r \
$tree $preds $species $traits $out ${SLURM_ARRAY_TASK_ID} 10000 \
$perm $seed Sleep.Total_daily_sleep_time.adult