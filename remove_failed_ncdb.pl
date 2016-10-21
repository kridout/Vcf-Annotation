#!/usr/bin/perl -w
#Combine vcfs with aditional database annotation

use warnings;
use strict;

#check for the correct input
if(@ARGV !=3){
die "  Format: perl remove_failed_cosmic.pl vcf_input vcf_output dbname\n";
}

my $inputvcf=shift;
my $outputvcf=shift;
my $db=shift;
my @columns=();

open(IN, '<', $inputvcf) or die "Could not open input\n";
  open(OUT, '>', $outputvcf) or die "Could not open output\n";

  while(my $line=<IN>){ #move through the file one line at a time
    chomp($line);

    if($line=~m/^##.*/){
	print OUT "$line\n";
    }
    else {
	if($line=~m/^#CHROM/){
	    print OUT "$line\t$db\n";
	}
	else {
	    my @columns=split ("\t", $line);
	    my @last4=splice @columns, -4;
	    my $part1=join("\t", @columns);
	    my $part2=$last4[3];
	    print OUT "$part1\t$part2\n";
	}
    }
}


  close(OUT);
close(IN);
