# vocalLearning_TACIT

Includes script and commands for generating datasets for putamen rat-only model, and putamen multi-species model with TACIT pipeline. \
Followed with permulation methods for three different physical traits.

* negativeGCMatched \
Generates random GC matched dataset as negatives using BiasAway.

* ratModelDataset \
Generates training, validation, evaluation used in rat putamen model.

### Automated scripts
* filterNFasta.py: 
Filter fasta files with 'N's.

* halperMapPeak.sh: map peaks with halLiftover and HALPER.
* pValShiftTest.sh: generate p-value distribution and run RankSum test.

### Dependencies
* Most scripts requires: Bedtools; filterPeakName.py from OCROrthologPrediction; preprocessing.py from atac_data_pipeline.
* For permulation, requires TACIT.
* For CNN model training, prediction, requires mouse_sst.


