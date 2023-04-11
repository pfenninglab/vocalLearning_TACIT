#!/bin/bash
#SBATCH --partition=pool1
#SBATCH --job-name=geneTest
#SBATCH --cpus-per-task=1

remove=false

function usage()
{
    echo "-i peak file with permulation p values (csv)"
    echo "-b species specific peaks (bed)"
    echo "-t species TSS file (bed)"
    echo "-g gene names related to trait"
    echo "-r optional; remove temporary files"
    echo "-o output directory"
    echo "-n optional; file name in case of duplication"
}

outName=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -i)
      shift
      permCsv=$1
      ;;
    -b)
      shift
      speciesBed=$1
      ;;
    -t)
      shift
      speciesTSS=$1
      ;;
    -g)
      shift
      genes=$1
      ;;
    -r)
      shift
      remove=true
      ;;
    -o)
      shift
      outDir=$1
      ;;
    -n)
      shift
      outName=$1
      ;;
    -h)           
      usage
      exit 1
      ;;
    *)
      usage 
      exit 1
  esac
  shift
done


echo "output with file name: $outName"

filterPeak=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/d2_model_prediction/step7_filterPeakName.py
bedtools=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/bedtools

tmpDir=${outDir}/tmp

mkdir -p $tmpDir

csvFileName=$(basename $permCsv | cut -d. -f1)
bedFileName=$(basename $speciesBed | cut -d. -f1)
geneFileName=$(basename $genes | cut -d. -f1)


echo "get species coordinates"
python $filterPeak --unfilteredPeakFileName $speciesBed --unfilteredPeakNameCol 3 \
--peakListFileName $permCsv --peakNameCol 0  --splitCharacterPeakList , \
--outputFileName ${tmpDir}/${csvFileName}_${bedFileName}_coordinate.bed

echo "get species-specific peaks"
python $filterPeak --unfilteredPeakFileName $permCsv --unfilteredPeakNameCol 0 --splitCharacterUnfiltered , \
--peakListFileName ${tmpDir}/${csvFileName}_${bedFileName}_coordinate.bed --peakNameCol 3 \
--outputFileName ${tmpDir}/${csvFileName}_${bedFileName}.csv

echo "get species TSS associated with Trait"
python $filterPeak --unfilteredPeakFileName $speciesTSS --unfilteredPeakNameCol 3 \
--peakListFileName $genes --peakNameCol 0  --splitCharacterPeakList , \
--outputFileName ${tmpDir}/${bedFileName}_${geneFileName}_nearTss.bed

echo "get OCRs within 1Mbp of TSS"
$bedtools window -a ${tmpDir}/${bedFileName}_${geneFileName}_nearTss.bed -b ${tmpDir}/${csvFileName}_${bedFileName}_coordinate.bed \
 -w 1000000 > ${tmpDir}/${csvFileName}_${bedFileName}_nearPeak.bed

echo "get OCRs with p values"  
python $filterPeak --unfilteredPeakFileName ${tmpDir}/${csvFileName}_${bedFileName}.csv --unfilteredPeakNameCol 0  --splitCharacterUnfiltered , \
--peakListFileName ${tmpDir}/${csvFileName}_${bedFileName}_nearPeak.bed --peakNameCol 9 \
--outputFileName ${tmpDir}/${geneFileName}_peaks_near_trait.csv

sed -i "1i$(sed -n 1p $permCsv)" ${tmpDir}/${geneFileName}_peaks_near_trait.csv

echo "get the rest OCR"
python $filterPeak --unfilteredPeakFileName ${tmpDir}/${csvFileName}_${bedFileName}.csv --unfilteredPeakNameCol 0  --splitCharacterUnfiltered ,  \
--peakListFileName ${tmpDir}/${csvFileName}_${bedFileName}_nearPeak.bed --peakNameCol 9 --removePeaks \
--outputFileName ${tmpDir}/${geneFileName}_peaks_not_near_trait.csv

sed -i "1i$(sed -n 1p $permCsv)" ${tmpDir}/${geneFileName}_peaks_not_near_trait.csv

echo "generate plot"
plot=/projects/pfenninggroup/machineLearningForComputationalBiology/VocalLearningTACIT/code/putamen/plotWilcoxon.py
python $plot --d1 ${tmpDir}/${geneFileName}_peaks_near_trait.csv --d2 ${tmpDir}/${geneFileName}_peaks_not_near_trait.csv \
--output ${outDir}/${outName}_${geneFileName}_pshift_plot.png

if $remove; then
  echo "remove temporary files..."
  rm ${tmpDir}/${csvFileName}_${bedFileName}_coordinate.bed ${tmpDir}/${csvFileName}_${bedFileName}.csv \
  ${tmpDir}/${bedFileName}_${geneFileName}_nearTss.bed ${tmpDir}/${csvFileName}_${bedFileName}_nearPeak.bed \
  ${tmpDir}/${geneFileName}_peaks_not_near_trait.csv ${tmpDir}/${geneFileName}_peaks_near_trait.csv
fi

echo "done"

