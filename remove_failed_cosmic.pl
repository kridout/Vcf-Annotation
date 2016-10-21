#!/usr/bin/perl -w
#Combine vcfs with cosmic annotation

use warnings;
use strict;

#check for the correct input
if(@ARGV !=2){
die "  Format: perl remove_failed_cosmic.pl vcf_input vcf_output \n";
}

my $inputvcf=shift;
my $outputvcf=shift;
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
	    print OUT "$line";
	    print OUT "\tCOSMIC_v78\n";
	}

	else {


	    my @columns=split ("\t", $line);

	    if ($columns[15]!=-1){
		print OUT "$columns[0]\t$columns[1]\t$columns[2]\t$columns[3]\t$columns[4]\t$columns[5]\t$columns[6]\t$columns[7]\t$columns[8]\t$columns[9]\t$columns[10]\t$columns[11]\t$columns[12]\t$columns[13]\t$columns[16]\n";
	    }
	    else {
		print OUT "$columns[0]\t$columns[1]\t$columns[2]\t$columns[3]\t$columns[4]\t$columns[5]\t$columns[6]\t$columns[7]\t$columns[8]\t$columns[9]\t$columns[10]\t$columns[11]\t$columns[12]\t$columns[13]\t$columns[14]\n";
	    }
	}
    }
}


  close(OUT);
close(IN);
