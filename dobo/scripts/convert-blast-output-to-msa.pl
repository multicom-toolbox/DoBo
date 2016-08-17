#!/usr/bin/perl -w
###############################################################################
# Name %n  : convert-blast-output-to-msa.pl
#
# Author: Jesse Eickholt
# URL: http://merit.oryo.us
# Date: Mon Aug 9 2010
###############################################################################

use strict;

if (@ARGV ne 3) {
  print "Usage: $0 <fasta.seq> <blast.output> <output.file>";
  exit;
}

my @msa=();

open FASTA, "<" . $ARGV[0] || die "Couldn't open fasta file.\n";
my @fasta = <FASTA>;
close FASTA;

open MSA, ">" . $ARGV[2] || die "Couldn't create MSA file.\n";

shift @fasta;
chomp(@fasta);
my $seq = join('', @fasta);
my $seq_length = length($seq);

# We'll fill in start/end gaps with '.', pulling them from this dots string
my $dots = '';
for(my $i = 0; $i <= $seq_length; $i++) {
  $dots .= '.';
}

# Grab the matching sequences from the blast output 
open BLAST, "<" . $ARGV[1] || die "Couldn't open blast output file.\n";
my @lines = <BLAST>;
close BLAST;

# Skip down to first alignemt, should start with a >
while(@lines > 0 && $lines[0] !~ m/^>/) {
  shift @lines;
}

# Process each alignment, adding processed alignment to msa 
while(@lines > 0) {
  my $query = '';
  my $subject = '';
  my $offset = -1;

  while(@lines > 0 && $lines[0] !~ m/^\s*Score/) {
    shift @lines;
  }

  if(@lines == 0) {
    last;
  }

  # Handle score line here if desired, print $lines[0];
  shift @lines;
  # Handle stats line here if desired, 
  shift @lines;
  
  while(@lines > 0 && $lines[0] !~ m/^Query/) {
    shift @lines;
  } 

  # Get offset and read first subject, query lines
  while($lines[0] =~ m/Query/) {
    my @fields = split(/\s+/, $lines[0]);
    if($offset < 0) { 
      $offset = $fields[1]; 
    }
    $query .= $fields[2];
    shift @lines; shift @lines;
    @fields = split(/\s+/, $lines[0]);
    $subject .= $fields[2];
    shift @lines; shift @lines;
  }

  # Handle any gaps in query, ie remove gap in query and corresponding residue in subject
  for(my $i = length($query) - 1; $i >= 0; $i--) {
    if(substr($query, $i, 1) eq '-') {
      substr($query, $i, 1, '');
      substr($subject, $i, 1, '');
    }
  }

    
  # Sanity check
  if(length($subject) != length($query)) {
    print "ERROR: Subject and query strings not the same length!";
  }

  $subject =~ s/-/\./g;
  $subject = substr($dots, 0, $offset-1) . $subject;
  if($seq_length - length($subject) > 0) {
    $subject .= substr($dots, 0, $seq_length - length($subject));
  } 

  push @msa, $subject;
}


# Output number of sequences in MSA 

print MSA "" . @msa . "\n";
print MSA "$seq\n";
foreach my $msa_t(@msa) {
  print MSA $msa_t . "\n";
}

close MSA;

