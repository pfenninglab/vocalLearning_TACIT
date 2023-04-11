#!/bin/bash
#SBATCH --partition=pool1
#SBATCH --array=1-224%8
#SBATCH --output=log/getFasta_%A_%a.txt

extendPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/extendPeak.py
filterFasta=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/filterNFasta.py
mapDir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/mergedMap
fastaDir=/projects/pfenninggroup/machineLearningForComputationalBiology/halLiftover_chains/data/raw_data/2bit/fasta
extendDir=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/extendPeak
outFasta=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/fasta
list=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/superModelPredict/ratMapMammal/species.txt

tmpSpecies=$(sed -n ${SLURM_ARRAY_TASK_ID}p $list);
species=${tmpSpecies/$'\r'/}
FASTA=${fastaDir}/${species}.fa
echo "processing $species"
echo "extend peak"
python $extendPeak expand_peaks -i ${mapDir}/${species}.enhancerMapped.bed \
-o ${extendDir}/${species}_extended.bed -l 500
echo "extract fasta"
~/tool/bedtools getfasta -nameOnly -fi $FASTA -bed ${extendDir}/${species}_extended.bed -fo ${outFasta}/${species}_enhancerMapped.fa
echo "filter fasta"
python $filterFasta --inputFasta ${outFasta}/${species}_enhancerMapped.fa \
--outputFasta ${outFasta}/${species}_enhancerMapped_filtered.fa
echo "done"