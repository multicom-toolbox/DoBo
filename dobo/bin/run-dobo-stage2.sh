#!/bin/bash

SCRIPT_DIR="/rose/space1/bap54/temp/dobo-share/scripts/"
PROGRAM_DIR="/rose/space1/bap54/temp/dobo-share/programs/"
MODELS_DIR="/rose/space1/bap54/temp/dobo-share/models/"
export LD_LIBRARY_PATH=/rose/space1/bap54/temp/dobo-share/lib/:$LD_LIBRARY_PATH

if [[ $# -ne 2 ]]; then 
  echo "Usage: $0 <fasta> <output_fname>"
  exit
fi

fasta=$1
output_fname=$2

prot_msa="prot.msa"
prot_ss_sa="prot.ss_sa"
prot_feat="prot.feat"
prot_stage_output="stage.output"
prot_stage_list="stage.lst"
prot_signals="signals"

# Generate msa
$SCRIPT_DIR/generate-msa.sh $fasta $prot_msa

# Predict ss_sa
$PROGRAM_DIR/sspro4.1/bin/predict_ss_sa.sh $fasta $prot_ss_sa

# Create feature file
$SCRIPT_DIR/generate-msa-features-w-zscore.pl $fasta $prot_msa $prot_ss_sa 45 45 41 $prot_feat

# Classify sites
$PROGRAM_DIR/svmlight/svm_classify $prot_feat $MODELS_DIR/stage2_uber $prot_stage_output
$SCRIPT_DIR/convert-svm-output-to-list.pl $prot_feat $prot_stage_output $prot_stage_list

$SCRIPT_DIR/score-signal-sites.sh $prot_feat $prot_stage_output $prot_signals

cp -v $prot_signals $output_fname

