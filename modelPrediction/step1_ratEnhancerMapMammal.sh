#!/bin/bash
#SBATCH -p pfen1
#SBATCH -w compute-1-12
#SBATCH --mem=10G
#SBATCH --array=1-224%5
#SBATCH --output=log/ratMap_%a.txt

list=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/ratMapMammal/species.txt
rat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/ratMapMammal/rat_enhancer.bed
tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list);
species=${tmpSpecies/$'\r'/}
echo "processing $species";
/home/tianyul3/codes/atac_data_pipeline/scripts/halper_map_peak_orthologs.sh \
-s Rattus_norvegicus \
-t $species \
-o /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/ratMapMammal \
-b $rat
