#!/usr/bin/perl -w
###############################################################################
# Name %n  : generate-msa-features-w-zscore.pl
# Desc %d  : Generate a quasi-svmlight features file.  The data is classified
#  into four classes and must be post processed before being feed into 
#  SVM light
# Input %i : Fasta, msa (generate-profile), ss_sa (sspro), min domain length,
#   min gap length, window size
# Output %o: Label plus features sent to stdout
#
# Author: Jesse Eickholt
# URL: http://merit.oryo.us
# Date: Thu Aug 12 2010
###############################################################################

my $in_boundary_cutoff = 20;
my $max_msa_count = 10000;
my $max_unique_signals = 35;

use strict;

if (@ARGV ne 7 ) {
  print "Usage: $0 <fasta> <msa> <ss_sa> <min_gap_length> <min_domain_length> <window_size> <output.file>\n";
  print "   Ex: $0 1h0z-A.fasta 1h0z-A.align 1h0z-A.ss_sa 40 40 20 1h0z-A.feat";
  exit;
}

open FASTA, "<" . $ARGV[0] || die "Couldn't open fasta file.\n";
my @fasta=<FASTA>;
chomp @fasta;
my $header = shift @fasta; # dispose of header
my @parts = split(/[\s|,]+/,$header);
my $id = $parts[0];
my $seq = join('', @fasta);
my @seq = split(//, $seq);

close FASTA;

open SS_SA, "<" . $ARGV[2] || die "Couldn't open ss_sa file.\n";
my @ss_sa=<SS_SA>;
chomp @ss_sa;
my @ss = split(//, $ss_sa[2]);
my @sa = split(//, $ss_sa[3]);
close SS_SA;

my $min_gap_length = $ARGV[3];
my $min_domain_length = $ARGV[4]; 
my $window_size = $ARGV[5];
my $output_filename = $ARGV[6];

my @signals = ();
my @counts =();
my @s_counts=();
for(my $i = 0; $i<@seq; $i++) {
  $signals[$i] = ' ';
  $counts[$i] = 0;
  $s_counts[$i] = 0;
}

open MSA, "<" . $ARGV[1] || die "Couldn't open alignment file.\n";
my @msa = <MSA>;
chop @msa;
my $msa_seq_count = shift @msa; # Get rid of first line, msa seq count
close MSA;

# First get a per residue signal count
foreach my $seq_t (@msa) {
  
  # Sanity check
  if(length($seq_t) ne @seq) {
    die "Length mismatch between fasta and a sequence in MSA.  Bail on " . $ARGV[1] . "!\n";
  } 

  
  my $left_gap = 0; 
  while($left_gap < length($seq_t) && substr($seq_t, $left_gap, 1) eq '.') {
    $left_gap++;
  } 

  my $right_gap = 1;
  while($right_gap < length($seq_t) && substr($seq_t, -$right_gap, 1) eq '.' ) {
    $right_gap++;
  }

  if(length($seq_t) - $left_gap - $right_gap >= $min_domain_length) {

    if($left_gap >= $min_gap_length) {
      $counts[$left_gap]++;
    }

    if($right_gap >= $min_gap_length) {
      $counts[length($seq_t) - $right_gap]++;
    }

    # Note that left_gap and length - right_gap give boundary residues and 
    # are index from 0

  }

}

# Smooth out counts
for(my $i = 0; $i < length($seq); $i++) {
  for(my $j = $i -5; $j < $i+5; $j++) {
    if($j >= 0 && $j < length($seq)) {
      $s_counts[$i]+= $counts[$j];
    }
  }
}

my @z_counts = calc_zscores(@s_counts);

my $msa_count = 0;
my $new_signal = 0;
foreach my $seq_t (@msa) {
  
  # Sanity check
  if(length($seq_t) ne @seq) {
    die "Length mismatch between fasta and a sequence in MSA.  Bail!\n";
  } 

  
  my $left_gap = 0; 
  while($left_gap < length($seq_t) && substr($seq_t, $left_gap, 1) eq '.') {
    $left_gap++;
  } 

  my $right_gap = 1;
  while($right_gap < length($seq_t) && substr($seq_t, -$right_gap, 1) eq '.' ) {
    $right_gap++;
  }

  if(length($seq_t) - $left_gap - $right_gap >= $min_domain_length) {

    if($left_gap >= $min_gap_length) {
      if($signals[$left_gap] ne '*') { $new_signal++;}
      $signals[$left_gap] = '*';
      $counts[$left_gap]++;
    }

    if($right_gap >= $min_gap_length) {
      if($signals[$right_gap] ne '*') {$new_signal++;}
      $signals[length($seq_t) - $right_gap] = '*';
      $counts[$right_gap]++;
    }

    # Note that left_gap and length - right_gap give boundary residues and 
    # are index from 0

  }

  $msa_count++;
  if($msa_count > $max_msa_count) {
    last;
  }

  if($new_signal > $max_unique_signals) { last; }

}


# Generate features for each signal

my @residue_probs = residue_prob_from_msa((($msa_seq_count > $max_msa_count) ? $max_msa_count : $msa_seq_count) ,@msa);
my $half = int($window_size/2);

open FEAT_FILE, ">$output_filename";

for(my $i = 0; $i<@signals; $i++) {
  if($signals[$i] ne ' ') {

    print FEAT_FILE "# $id, " . length($seq) . ", " . ($i+1) . ", <- name , length, signal location \n";

    # For SVMlight, when classifying, the label doesn't count.  Give a dummy value.
    print FEAT_FILE "0 ";

    my $start = $i - $half;
    my $stop = $i + $half;

    # Sanity check 
    if($start < 1 || $stop > length ($seq)) {
      die "Feature window extends beyond sequence boundaries!!!";
    }

    my @feature =();
    
    for(my $j = $start - 1; $j < $stop; $j++) {

      foreach my $field_t(@{$residue_probs[$j]}) {
        push @feature, sprintf("%6f", $field_t);
      }

      if ($ss[$i]  eq "H") {
        push @feature, 1;
        push @feature, 0;       
        push @feature, 0;       
      } elsif ($ss[$i] eq "E") {
        push @feature, 0;
        push @feature, 1;       
        push @feature, 0;       
      } else {
        push @feature, 0;
        push @feature, 0;       
        push @feature, 1;       
      }

      if ($sa[$i] eq "e") {
        push @feature, 1;
        push @feature, 0;       
      } else {
        push @feature, 0;
        push @feature, 1;       
      }

    }
    # Here, may want to add number of adjacent signals per dr cheng's implementation
    push @feature, (length($seq) / 100);

    push @feature, ($i/ 100);
    push @feature, ((length($seq) - $i)/ 100);
   
    my $near_signal_count = 0;
    for(my $j = $i - 5; $j < $i + 5; $j++) {
      if($signals[$j] ne ' ' && $j != $i) {
        $near_signal_count++;
      }
    }
    push @feature, ($near_signal_count);
    push @feature, $z_counts[$i];

    for(my $k = 0; $k < @feature; $k++) {
      print FEAT_FILE " " . ($k+1) . ":" . $feature[$k];
    }
    print FEAT_FILE "\n";
  }

}

close FEAT_FILE;

sub residue_prob_from_msa { 
  my($num_of_sequences, @sequences);
  my ($aa_str, @residue_prob, $i, $j, $aa, $idx, $length);

  ($num_of_sequences, @sequences) = @_;
  chomp($num_of_sequences);
  chomp(@sequences);

  $aa_str = "ACDEFGHIKLMNPQRSTVWY"; #20 std aa
  $length = length($sequences[0]);

  #profile size: 20 + one gap, if all zero, means not exist(for pos outside of window)
  @residue_prob = ();
  for ($i = 0; $i < $length; $i++) {
    for ($j = 0; $j < 21; $j++) {
     $residue_prob[$i][$j] = 0;
    }
  }


  for ($i = 0; $i < $length; $i++) {
    for($j = 0; $j < $num_of_sequences; $j++) {
      $aa = substr($sequences[$j], $i, 1);
      $aa = uc($aa);
      $idx = index($aa_str, $aa);
      if ($idx < 0) { #gap case or unknonw        
        #treated as a gap
        $idx = 20;
      }
      $residue_prob[$i][$idx] +=  (1 / $num_of_sequences);
    }
  }

  return @residue_prob;
}

sub calc_zscores {
  my @data = @_;
  my @zscores = ();
  my $mu = calc_mu(@data);
  my $sigma = calc_sigma(@data);

  foreach my $value (@data) {
    if($sigma > 0) {
      push (@zscores, ($value - $mu)/$sigma);
    } else { 
      push (@zscores, 0);
    }
  }

  return @zscores;

}

sub calc_mu {

  my @data = @_;
  my $sum = 0;

  foreach my $value (@data) {
    $sum += $value;
  }
  
  if(@data > 0) {
    return $sum / @data;
  } else {
    return 0;
  }

}

sub calc_sigma {
  my @data = @_;
  my $deviations = 0;
  my $mu = calc_mu(@data);

  foreach my $value (@data) {
    $deviations += ($value - $mu) ** 2;
  }
 
  if(@data > 1) {
    sqrt($deviations / (@data -1));
  } else {
    return 0;
  }

}


