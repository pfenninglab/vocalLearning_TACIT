#!/bin/bash
#SBATCH --partition=pfen3
#SBATCH --gres=gpu:1
#SBATCH --mem=12G
#SBATCH --output=log/pred_%A_%a.txt
#SBATCH --array=1-224%4

fastaDir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/fasta/filtered
model=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenModel/putamenSuperModel/model-79x6vum9.h5
outDir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/prediction 

source ~/.bashrc
conda activate keras2-tf27

list=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/macaqueMapMammal/species.txt
tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list);
species=${tmpSpecies/$'\r'/}
fasta=${fastaDir}/${species}_enhancerMapped_filtered.fa
echo "processing $species";
python ~/codes/repo/mouse_sst/get_activations.py \
-model $model -in_file $fasta \
-out_file ${outDir}/${species}"_predict.npy"
echo "prediction done"
