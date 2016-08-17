#!/bin/bash
###############################################################################
# Name %n  : generate-msa.sh
# Desc %d  : Create an alignment which can be used the generate a profile
# Input %i : A fasta file
# Output %o: An MSA for the sequence
#
# Requires: convert-blast-output-to-msa.pl
#
# Author: Jesse Eickholt
# URL: http://merit.oryo.us
# Date: Wed May 26 2010
###############################################################################

#BLAST_PATH="/home/jlec95/programs/ncbi-blast-2.2.23+/bin"
#BLAST_NR_DB="/home/jlec95/programs/blast/db/nr"
#BLASTMAT="/home/jlec95/programs/blast/matrices"

BLAST_PATH="/rose/space1/bap54/temp/dobo-share/programs/ncbi-blast-2.2.24+/bin"
BLAST_NR_DB="/rose/space1/bap54/temp/dobo-share/db/nr"
BLASTMAT="/rose/space1/bap54/temp/dobo-share/programs/ncbi-blast-2.2.24+/matrices"
CONVERT_PATH="/rose/space1/bap54/temp/dobo-share/scripts";

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <seq.fasta> <output.file>";
  exit;
fi

if [ -n "${BLASTMAT:+x}" ]; then
  export BLASTMAT;
fi

# First, psi-blast to find relatives
echo "Running PSI-Blast...";
$BLAST_PATH/psiblast -query "$1" -evalue .001 -db "$BLAST_NR_DB" -num_iterations 3 -outfmt "0"\
  -out /tmp/$$_psiblast.out -num_alignments 2000

echo "Converting output to MSA";
$CONVERT_PATH/convert-blast-output-to-msa.pl "$1" /tmp/$$_psiblast.out "$2"

/bin/rm /tmp/$$_psiblast.out 

