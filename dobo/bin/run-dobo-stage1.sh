#!/bin/bash -e

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

prot_msa="/tmp/$$_prot.msa"
prot_ss_sa="/tmp/$$_prot.ss_sa"
prot_feat="/tmp/$$_prot.feat"
prot_stage_output="/tmp/$$_stage.output"
prot_stage_list="/tmp/$$_stage.lst"
prot_signals="/tmp/$$_signals"

echo "Printing id.."
echo $$
trap cleanup 1 2 3 6

function cleanup {
  if [[ -e $prot_msa ]]; then
    /bin/rm -f $prot_msa2
  fi
  if [[ -e $prot_ss_sa ]]; then
    /bin/rm $prot_ss_sa
  fi
  if [[ -e $prot_feat ]]; then
    /bin/rm $prot_feat
  fi
  if [[ -e $prot_stage_output ]]; then
    /bin/rm $prot_stage_output
  fi
  if [[ -e $prot_stage_list ]]; then
    /bin/rm $prot_stage_list
  fi
  if [[ -e $prot_signals ]]; then
    /bin/rm $prot_signals
  fi
} 

# Generate msa
$SCRIPT_DIR/generate-msa.sh $fasta $prot_msa

# Predict ss_sa
$PROGRAM_DIR/sspro4.1/bin/predict_ss_sa.sh $fasta $prot_ss_sa

# Create feature file
$SCRIPT_DIR/generate-msa-features-w-zscore.pl $fasta $prot_msa $prot_ss_sa 45 45 41 $prot_feat

# Classify sites
$PROGRAM_DIR/svmlight/svm_classify $prot_feat $MODELS_DIR/stage1_uber $prot_stage_output

$SCRIPT_DIR/process-stage1-output.sh $prot_stage_output $output_fname

#cleanup
