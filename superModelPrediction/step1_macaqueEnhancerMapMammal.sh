#!/bin/bash
#SBATCH -p pfen1
#SBATCH -w compute-1-12
#SBATCH --mem=10G
#SBATCH --array=1-224%8
#SBATCH --output=log/ratMap_%a.txt

list=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/macaqueMapMammal/species.txt
macaque=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/superModel/positiveTrain/macaque/macaque_filterRat_putamenEnhancer_gb.bed
tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list);
species=${tmpSpecies/$'\r'/}
echo "processing $species";
/home/tianyul3/codes/atac_data_pipeline/scripts/halper_map_peak_orthologs.sh \
-s Macaca_mulatta \
-t $species \
-o /projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/macaqueMapMammal \
-b $macaque
