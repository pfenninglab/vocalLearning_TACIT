#!/bin/bash
#SBATCH --partition=pfen1
#SBATCH --error=log/svmTrain_%A_%a.err.txt
#SBATCH --output=log/svmTrain_%A_%a.txt
#SBATCH --mem=24G
#SBATCH --array=1-7%2

posTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_pos_train_svm_filter.fa
negTrain=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_neg_train_svm_filter.fa
wd=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/ratSVM
posVal=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_pos_val_svm_filter.fa
negVal=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/data/putamenData/ratModel/rat_neg_val_svm_filter.fa

cd /home/tianyul3/codes/svm/lsgkm/src

# for SLURM_ARRAY_TASK_ID in {1..7}; do

l=$((${SLURM_ARRAY_TASK_ID}+5))
k=$(($l-4))
outModel=${wd}/rat_svm_t0_len${l}
../bin/gkmtrain -l ${l} -k ${k} -m 4096 $posTrain $negTrain $outModel
echo "traing completed for array ${SLURM_ARRAY_TASK_ID}"

../bin/gkmpredict $posVal ${outModel}.model.txt ${outModel}_pred_positive.txt
../bin/gkmpredict $negVal ${outModel}.model.txt ${outModel}_pred_negative.txt
echo "prediction completed for array ${SLURM_ARRAY_TASK_ID}"

totalPos=$(cat ${outModel}_pred_positive.txt|wc -l)
totalNeg=$(cat ${outModel}_pred_negative.txt|wc -l)

while IFS=$'\t' read -r -a array; do
if (( $(echo "${array[1]} > 0" |bc -l) )); then
trueP=$(($trueP+1))
fi
done < ${outModel}_pred_positive.txt

while IFS=$'\t' read -r -a array; do
if (( $(echo "${array[1]} < 0" |bc -l) )); then
trueN=$(($trueN+1))
fi
done < ${outModel}_pred_negative.txt

echo "sensitivity is $(echo "$trueP / $totalPos " | bc -l)" >> ${outModel}_result.txt
echo "specificity is $(echo "$trueN / $totalNeg" | bc -l)" >> ${outModel}_result.txt
echo "precision is $(echo "$trueP / ($totalNeg - $trueN + $trueP)" | bc -l)" >> ${outModel}_result.txt
# done
