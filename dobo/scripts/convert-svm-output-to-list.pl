#!/usr/bin/perl -w
###############################################################################
# Name %n  : convert-svm-output-to-list.pl
# Desc %d  : Combine svm features and svm output file into one file
#
# Author: Jesse Eickholt
# Date: Mon Aug 23 2010
###############################################################################

# use lib '/home/jlec95/lib'
# use MyPDBUtils qw(fn-name);
use strict;

if (@ARGV ne 3) {
  print "Usage: $0 <features_file> <svm_output> <list_output>";
  exit;
}

open FEATURES, "<" . $ARGV[0] || die "Can't open features file";
my @features=<FEATURES>;
chomp(@features);
close FEATURES;

open SVM_OUTPUT, "<" . $ARGV[1] || die "Can't open svm output file";
my @svm_output=<SVM_OUTPUT>;
chomp(@svm_output);
close SVM_OUTPUT;

open LIST_OUTPUT, ">" . $ARGV[2] || die "Can't open output file.";

if(@features ne 2 * @svm_output) {
  print "Features file and svm output do not match.  One as too many lines!";
#  exit;
}

while(@features > 0) {
  my $header = shift @features;
  my $feature_t = shift @features;

  my @fields = split(/,/, $header);
  my $name = $fields[0];
  $name =~ s/^[^>]*>//;
  $name =~ s/:/-/;
  $name =~ s/ //g;

  my $length = $fields[1];
  $length =~ s/[ a-zA-Z:]//g;
  
  my $location = $fields[2];
  $location =~ s/[ A-Za-z:]//g;

  @fields = split(/\s+/, $feature_t);
  my $true = $fields[0];

  my $score = shift @svm_output;

print LIST_OUTPUT "$name $length $location $true $score \n";  

}

close LIST_OUTPUT;
