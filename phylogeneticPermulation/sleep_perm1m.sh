#!/bin/bash
#SBATCH -p pool1
#SBATCH --job-name=perm1m
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm1m_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/perm1m_%A_%a.txt
#SBATCH --mem=8G
#SBATCH --time=72:00:00
#SBATCH --array=1-217%80
source ~/.bashrc
conda activate hal

seed=`od --read-bytes=4 --address-radix=n --format=u4 /dev/random | awk '$1>=2^31{$1-=2^32}1'`
data="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep"
tree="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_ChrX_lessGC40_241species_30Consensus.tree"
preds="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm1m_predictionMatrix.tsv"
species="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/species.txt"
traits="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/Zoonomia_phenotypes_12-14-21.csv"
out="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/perm1m/sleep_perm_1m.csv"
perm="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_perm1m_peakList.csv"

Rscript /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/TACIT/ocr_phylolm_conditional.r \
$tree $preds $species $traits $out ${SLURM_ARRAY_TASK_ID} 1000 \
$perm $seed Sleep.Total_daily_sleep_time.adult