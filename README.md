# vocalLearning_TACIT

Includes script and commands for generating datasets for putamen rat-only model, and putamen multi-species model with TACIT pipeline. \
Followed with permulation methods for three different physical traits.

* multiSpeciesModelPrediction \
Using trainied putamen multi-species model to make predictions on OCRs of 224 mammals. 

* negativeGCMatched \
Generates random GC matched dataset as negatives using BiasAway.

* putamenMultiSpeciesModelDataset \
Generates training, validation, evaluation used in multi-species (rat, macaque, bat) putamen model.

* phylogeneticPermulation \
Find association between predicted enhancer activities and physical traits, including longevity(Maximum life span), total daily sleep, and vocal learning, with TACIT. 

* ratModelDataset \
Generates training, validation, evaluation used in rat putamen model.

* ratPutamenSVM: uses SVM to provide insights for CNN hyperparameter tuning.
* humanPutamenDataset: Generates training, validation, evaluation used in human putamen model.


### Automated scripts
* TACIT pipelines: automate dataprocessing including filtering, plotting, and generating matrix with permulationList.py, plotPDist.R, bhCorrection.R, qValue.R, filterNFasta.py.
* ATAC seq helpers: automate mapping peaks from halLiftover and HALPER with halperMapPeak.sh. Ortholog conversion for bat sequences with batFormatConvert.sh. 
* Model Prediction interpretation: automate testing p value distribution shift comparing prediction and literature with pValShiftTest.sh and plotWilcoxon.py

### Dependencies
* Conda environment: keras2-tf27.yml used for CNN training/predictions from [mouse_sst](https://github.com/pfenninglab/mouse_sst). For other scripts, use hal.yml.
*  Most scripts require: filterPeakName.py from [OCROrthologPrediction](https://github.com/pfenninglab/OCROrthologPrediction); preprocessing.py from [atac_data_pipeline](https://github.com/pfenninglab/atac_data_pipeline); convertChromNames.py from [TACIT](https://github.com/pfenninglab/TACIT).
*  Phyloenetic permulation, requires [TACIT](https://github.com/pfenninglab/TACIT).
