#!/bin/bash
#SBATCH --partition=pfen3
#SBATCH --array=1-55%4
#SBATCH --output=log/sm_predict_%A_%a.txt
#SBATCH --error=log/sm_predict_err_%A_%a.txt

fastaDir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/gliresMapFasta/ppl_filFasta
model=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/putamenSuperModel/model_1_81e9apw5.h5
out=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/predictGlires

cd ~/codes/repo/mouse_sst
source ~/.bashrc
conda activate keras2-tf27
# for SLURM_ARRAY_TASK_ID in {1..55}; do
glires=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/predictGlires/glires_species.txt
tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $glires);
species=${tmpSpecies/$'\r'/}
fasta=${fastaDir}/${species}"_filtered.fasta"
echo "processing $species";
echo "file: $fasta";
python scripts/get_activations.py \
-model $model -in_file $fasta \
-out_file ${out}/${species}"_predict.npy"
# done