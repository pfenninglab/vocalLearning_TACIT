#!/bin/bash
#SBATCH -p pool1
#SBATCH --job-name=phylolm
#SBATCH --cpus-per-task=1
#SBATCH --error=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/phylo_err_%A_%a.txt
#SBATCH --output=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/log/phylo_%A_%a.txt
#SBATCH --mem=4G
#SBATCH --time=72:00:00
#SBATCH --array=1-1
source ~/.bashrc
conda activate hal

seed=`od --read-bytes=4 --address-radix=n --format=u4 /dev/random | awk '$1>=2^31{$1-=2^32}1'`
data="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep"
tree="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/longevity/Zoonomia_ChrX_lessGC40_241species_30Consensus.tree"
preds="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/superModelPredictMatrixRevised.tsv"
species="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/species.txt"
traits="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/totalSleep/Zoonomia_phenotypes_12-14-21.csv"
out="/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenPermulation/sleep/sleep_phylolm_result.csv"

Rscript /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/TACIT/ocr_phylolm.r \
$tree $preds $species $traits $out ${SLURM_ARRAY_TASK_ID} 1 \
0 $seed Sleep.Total_daily_sleep_time.adult 
