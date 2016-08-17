#!/bin/bash
###############################################################################
# Name %n  : process-stage1-output.sh
# Desc %d  : Classify a protein a single or multidomain based on stage1 output
###############################################################################

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <stage1.output> <output>";
  exit;
fi

type='single domain';

while read line; do
  if [[ `echo $line | cut -d'.' -f 1` -gt 0 ]]; then
    type='multi-domain';
  fi
done < $1

echo $type > $2;
