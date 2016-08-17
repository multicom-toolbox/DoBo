#!/usr/bin/perl -w
###############################################################################
# Name %n  : show-signal-sites.pl
# Desc %d  : Visualize results for stage 2 classification
###############################################################################

use strict;

my $min_domain_len = 40;

if(@ARGV ne 5) {
  print "Usage: $0 <fasta> <ss_sa> <signals.lst> <confidence> <output>";
  exit;
}

my $conf_threshold = $ARGV[3];

open FASTA, "<" . $ARGV[0] || die "Couldn't open fasta file.";
my @fasta=<FASTA>;
chomp @fasta;
shift @fasta; # dispose of header
my $seq = join('', @fasta);
my @seq = split(//, $seq);

close FASTA;

open SS_SA, "<" . $ARGV[1] || die "Couldn't open ss_sa file.";
my @lines=<SS_SA>;
my @ss = split(//, $lines[2]);
my @sa = split(//, $lines[3]);
close SS_SA;

my @signals = ();
#my @boundaries = ();
for(my $i = 0; $i < @seq; $i++) {
  $signals[$i] = ' ';
  # $boundaries[$i] = ' ';
}

open SIGNALS, "<" . $ARGV[2] || die "Couldn't open signals list.";
@lines=<SIGNALS>;
chomp @lines;
close SIGNALS;

while(@lines > 0) {
  my @fields = split(/ /, $lines[0]);
  if($fields[2] > $conf_threshold) {
    $signals[$fields[0] - 1] = 'X';
  } else {
  $signals[$fields[0] - 1] = '-';
  }
  shift @lines;
}

open OUTPUT, ">" . $ARGV[4] || die "Couldn't open output file\n";

my $i = 0;
while($i < @seq) {

  my $offset = 0;
  print OUTPUT "Idx:  ";
  while($offset < 80 && $i+$offset < @seq) {
    if(($i+$offset) % 20 == 0) {
      print OUTPUT (($i+$offset)/10)%10 . "0";
      $offset++;
    } else {
      if(($i+$offset) % 100 == 99 && $offset < 79) {
        print OUTPUT (($i+$offset+1)/100);
      } else {
        print OUTPUT ' ';
      }
    }
    $offset++;
  }
  print OUTPUT "\n";

  $offset = 0;
  print OUTPUT "SS:   ";
  while($offset < 80 && $i+$offset < @seq) {
    print OUTPUT $ss[$i+$offset];
    $offset++;
  }
  print OUTPUT "\n";

  $offset = 0;
  print OUTPUT "SA:   ";
  while($offset < 80 && $i+$offset < @seq) {
    print OUTPUT $sa[$i+$offset];
    $offset++;
  }
  print OUTPUT "\n";

  $offset = 0;
  print OUTPUT "Seq:  ";
  while($offset < 80 && $i+$offset < @seq) {
    print OUTPUT $seq[$i+$offset];
    $offset++;
  }
  print OUTPUT "\n";

#    $offset = 0;
#    print "Sig:    ";
#    while($offset < 80 && $i+$offset < @seq) {
#      print $sign[$i+$offset];
#      $offset++;
#    }
#    print "\n";

  $offset = 0;
  print OUTPUT "Pre:  ";
  while($offset < 80 && $i+$offset < @seq) {
    print OUTPUT $signals[$i+$offset];
    $offset++;
  }
  print OUTPUT "\n\n";

  $i+=$offset;
  
}

close OUTPUT;



