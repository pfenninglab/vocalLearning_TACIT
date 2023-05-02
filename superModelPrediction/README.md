## superModelPrediction

Requires a trained model, fasta gene files of interested species. \
Output: processed prediction matrix used for further assocation with physical traits, and phylogenetic permulations.

* step1: map from model species to target species. 
* step2: process the fasta files to 1. remove sequences with excessive N 2. peak extension.
* step3: use trained model to make prediction on processed files. 
* step4: remove inaccurate prediction (Gap>threshold) and generate the final matrix.
