#!/bin/bash
#SBATCH --partition=pfen1
#SBATCH --ntasks=2

# usage: sbatch mapPeak.sh -i $input_file -f species_map_from -t species_map_to -c optional_alignment_file

while test $# -gt 0; do
  case "$1" in
    -i)
      shift
      if test $# -gt 0; then
        export inputFile=$1
      fi
      shift
      ;;
    -f)
      shift
      if test $# -gt 0; then
        export fromSpecies=$1
      fi
      shift
      ;;
    -t)
      shift
      if test $# -gt 0; then
        export toSpecies=$1
      fi
      shift
      ;;
    -c)
      shift
      if test $# -gt 0; then
        export cacAlign=$1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [ -z "$cacAlign" ]; then 
cacAlign=/data/pfenninggroup/machineLearningForComputationalBiology/alignCactus/mam241/241-mammalian-2020v2.hal
fi

halLiftover=/home/ikaplow/RegulatoryElementEvolutionProject/src/hal/bin/halLiftover 
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools
halper=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/halper/halLiftover-postprocessing/orthologFind.py

fileDir="$(dirname "${inputFile}")"
fileName=${fileDir}/${fromSpecies}MapTo${toSpecies}

awk 'BEGIN{OFS="\t"}{print $1, $2+$10, $2+$10+1, $4}' ${inputFile}> ${fileName}_summits.narrowpeak
echo "generated summit file"

srun --exclusive -n 1 $halLiftover --bedType 4 $cacAlign \
$fromSpecies $inputFile \
$toSpecies ${fileName}_halLiftover.narrowpeak &

srun --exclusive -n 1 $halLiftover --bedType 4 $cacAlign \
$fromSpecies ${fileName}_summits.narrowpeak \
$toSpecies ${fileName}_summits_halLiftover.narrowpeak &
wait

echo "halLiftover completed"

python $halper -max_len 1000 -min_len 50 -protect_dist 5 -max_frac 2 \
-qFile $inputFile -tFile ${fileName}_halLiftover.narrowpeak \
-sFile ${fileName}_summits_halLiftover.narrowpeak \
-oFile ${fileName}_halper.narrowpeak -narrowPeak

echo "HALPER completed"









