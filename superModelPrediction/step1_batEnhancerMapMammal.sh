#!/bin/bash
#SBATCH -p pfen1
#SBATCH -w compute-1-12
#SBATCH --mem=10G
#SBATCH --array=1-224%6
#SBATCH --output=log/batMap_%a.txt

list=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/batMapMammal/species.txt
bat=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/batPositive/batMammal/bat_filterRatMacaque_putamenEnhancer.bed
tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list);
species=${tmpSpecies/$'\r'/}
echo "processing $species";
/home/tianyul3/codes/atac_data_pipeline/scripts/halper_map_peak_orthologs.sh \
-s Rousettus_aegyptiacus \
-t $species \
-o /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/batMapMammal \
-b $bat