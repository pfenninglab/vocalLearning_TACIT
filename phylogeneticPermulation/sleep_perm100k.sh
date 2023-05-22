#!/bin/bash
#SBATCH -p pool1
#SBATCH --job-name=perm100k
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm100k_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm100k_%A_%a.txt
#SBATCH --mem=8G
#SBATCH --time=72:00:00
#SBATCH --array=50,150,250,350,450,550,650,75,175,275,375,475,575,675
source ~/.bashrc
conda activate hal

seed=`od --read-bytes=4 --address-radix=n --format=u4 /dev/random | awk '$1>=2^31{$1-=2^32}1'`
data="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep"
tree="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_ChrX_lessGC40_241species_30Consensus.tree"
preds="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm100k_predictionMatrix.tsv"
species="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/species.txt"
traits="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_phenotypes_12-14-21.csv"
out="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/perm100k/sleep_perm_100k.csv"
perm="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm100k_peakList.csv"

Rscript /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/TACIT/ocr_phylolm_conditional.r \
$tree $preds $species $traits $out ${SLURM_ARRAY_TASK_ID} 1000 \
$perm $seed Sleep.Total_daily_sleep_time.adult