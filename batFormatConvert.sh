#!/bin/bash

function usage()
{
	echo "usage:"
	echo "-1 convert to bat1k in Cactus alignment"
	echo "sh batFormatConvert.sh -i input.bed"
	echo "-2 convert back to bat for filtering"
	echo "sh batFormatConvert.sh -i input.bed -r"
	echo "-k keep intermediate files"
	echo "requires as least 10G memory"
}

reverseConvert='FALSE'
keep='FALSE'
source ~/.bashrc

while [[ $1 != "" ]]; do
    case $1 in
        -i | --input ) shift
            inputFile=$1
            ;;
        -r | --reverse ) shift
			reverseConvert='TRUE'
			;;
		-k | --keepIntermediate ) shift
			keep='TRUE'
			;;
        -h | --help ) usage
            exit 1
            ;;
        *)
        usage
        exit 1
    esac
    shift
done

fileDir="$(dirname "${inputFile}")"
fileName=$(basename -- ${inputFile})
fileName="${fileName%.*}"
programName="batConvert"

echo ${fileDir}

seqName=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/BatGenome/SequenceNameToRefseqName_HLrouAeg4.txt
convChName=/home/ikaplow/RegulatoryElementEvolutionProject/src/RegElEvoCode/convertChromNames.py
batCactusFormat=/data/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/200MammalsFastas/SequenceNameToGenbankName_Rousettus_aegyptiacus.txt

if [[ $reverseConvert == 'FALSE' ]]
then 
	echo "Convert to bat1k "
	chainFile=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/HLrouAeg4.Rouage1.over.chain.gz
	python $convChName --bedFileName $inputFile --chromNameDictFileName $seqName \
	--chromNameDictReverse  --outputFileName ${fileDir}/${programName}_seqName.bed
	awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $4, $5, $6, int($7), int($8), int($9), $10}' ${fileDir}/${programName}_seqName.bed > ${fileDir}/${programName}_seqName_int.bed
	liftOver ${fileDir}/${programName}_seqName_int.bed $chainFile ${fileDir}/${programName}_lifted.bed ${fileDir}/${programName}_unlifted.bed
	awk 'BEGIN{OFS="\t"} {print $1".1", $2, $3, $4, $5, $6, $7, $8, $9, $10}' ${fileDir}/${programName}_lifted.bed > ${fileDir}/${programName}_lifted_genbank.bed
	python $convChName --bedFileName ${fileDir}/${programName}_lifted_genbank.bed --chromNameDictFileName $batCactusFormat \
	--chromNameDictReverse --outputFileName ${fileDir}/${fileName}_convertedBat1k.bed
else 
	echo "Convert back to original bat"
	python $convChName --bedFileName $inputFile --chromNameDictFileName $batCactusFormat \
	--outputFileName ${fileDir}/${programName}_genBank.bed
	awk 'BEGIN{OFS="\t"} {print substr($1, 1, length($1)-2) , $2, $3, $4, $5, $6, $7, $8, $9, $10}' ${fileDir}/${programName}_genBank.bed > ${fileDir}/${programName}_genBank_1.bed
	batChain=/projects/pfenninggroup/machineLearningForComputationalBiology/regElEvoGrant/LiftoverChains/RouAeg1.HLrouAeg4.over.chain.gz
	liftOver ${fileDir}/${programName}_genBank_1.bed $batChain ${fileDir}/${programName}_lifted.bed ${fileDir}/${programName}_unlifted.bed
	python $convChName --bedFileName ${fileDir}/${programName}_lifted.bed --chromNameDictFileName $seqName \
	--outputFileName ${fileDir}/${fileName}_convertedOriginal.bed
fi

if [[ $keep == 'FALSE' ]]; then
	echo "Remove intermediate files"
	rm ${fileDir}/${programName}*.bed
fi

echo "finished"