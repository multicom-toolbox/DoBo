#!/bin/bash
###############################################################################
# Name %n  : score-signal-sites.sh
# Desc %d  : 
# Input %i : 
# Output %o: 
#
# Author: Jesse Eickholt
# URL: http://merit.oryo.us
# Date: Thu Oct 28 2010
###############################################################################

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <features> <svmlight_output> <output>";
  exit;
fi

grep "^#" $1 | cut -d',' -f 3 | sed -e 's/\s+$//' > $$_sites.lst
paste $$_sites.lst $2 |\
  awk '{printf("%d %f ", $1, $2);
        if($2 < -1.5) {
          print ".37";
        } else if($2 < -1.2) {
          printf("%.2f", $2 * .08333 + .495);
        } else if($2 < -.16) {
          printf("%.2f", $2 * .30288 + .78);
        } else if($2 < 1.5){
          printf("%.2f", $2 * .144578 + .74313);
        } else {
          print ".95";
        }
        printf("\n");
       }' | sort -nr -k 3 > $3 

/bin/rm $$_sites.lst
