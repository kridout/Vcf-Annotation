#!/usr/bin/perl -w
#Calculate VAF from the ALT Depth and the total DEPTH

use warnings;
use strict;

#check for the correct input
if(@ARGV !=2){
die "  Format: perl calculate_vaf.pl vcf_input vcf_output \n";
}
#chr2	79110972	.	G	T	.	PASS	NT=ref;QSS=88;QSS_NT=86;SGT=GG->GT;SOMATIC;TQSS=1;TQSS_NT=1	DP:FDP:SDP:SUBDP:AU:CU:GU:TU	47:0:0:0:0,0:0,0:47,48:0,0	89:1:0:0:0,0:0,0:51,52:37,37

#read in the filenames
my $inputvcf=shift;
my $outputvcf=shift;

my $vaf_normal=0;
my $vaf_tumour=0;
my $altdepth1=0;
my $altdepth2=0;
my $altdepth3=0;
my $altdepth=0;
my $DPnorm=1;
my $DPtumour=1;
my $QSS=0;
my @normals=();
my @tumours=();
my %format_normal_snvs=();
my %format_tumour_snvs=();
my @formatnames=();

#read in the file
open(IN, '<', $inputvcf) or die "Could not open input\n";
  open(OUT, '>', $outputvcf) or die "Could not open output\n";;

  while(my $line=<IN>){ #move through the file one line at a time
  	chomp($line);
     @normals=();
     @tumours=();
     %format_normal_snvs=();
     %format_tumour_snvs=();
      @formatnames=();
  	if($line=~m/^##.*/){
print OUT "$line\n";
  	}
  	else {
  	if($line=~m/^#CHROM/){
  		print OUT "$line";
  		print OUT "\tQSS\tVAF_normal\tVAF_tumour\n";
  	}else {

  	$vaf_normal=0;
  	$vaf_tumour=0;
  	$QSS=0;

  	@normals=();
  	@tumours=();
	my @columns=split ("\t", $line); #split the line at the tabs
  my $ref=$columns[3];
    my $alt=$columns[4];
    my $info_qss=$columns[7];
    my $format=$columns[8];
    my $info1=$columns[9];
    my $info2=$columns[10];

	 @normals=split(":",$info1);
     @tumours=split(":",$info2);

    if ($info_qss=~m/QSS\=(\d+)(.*)/){
 	$QSS=$1;
    }
    if ($info_qss=~m/QSI\=(\d+)(.*)/){
  $QSS=$1;
    }
    #DP- 0
    #A - 4
    #C - 5
    #G - 6
    #T - 7
    @formatnames=split(":",$format);
@format_normal_snvs{@formatnames} = @normals;
@format_tumour_snvs{@formatnames}=@tumours;


    $DPnorm=$format_normal_snvs{"DP"};
    $DPtumour=$format_tumour_snvs{"DP"};
    #36: 0:0: 0: 0,1: 0,0: 36,36: 0,0
    #141:0:0:0:13,16:0,0:128,137:0,0
    #vaf for normals
    if ($alt eq "A"){
    $altdepth1=$format_normal_snvs{"AU"};
    my @alt1=split(",",$altdepth1);
    $altdepth=(sort { $a <=> $b } @alt1)[0];
    $altdepth2=$format_tumour_snvs{"AU"};
    my @alt2=split(",",$altdepth2);
    $altdepth3=(sort { $a <=> $b } @alt2)[0];

    if($DPnorm !=0){
    $vaf_normal=$altdepth/$DPnorm;
    }
    if($DPtumour !=0){
$vaf_tumour=$altdepth3/$DPtumour;
    }
    }
    ############
      if ($alt eq "C"){
    $altdepth1=$format_normal_snvs{"CU"};
    my @alt1=split(",",$altdepth1);
    $altdepth=(sort { $a <=> $b } @alt1)[0];
    $altdepth2=$format_tumour_snvs{"CU"};
    my @alt2=split(",",$altdepth2);
    $altdepth3=(sort { $a <=> $b } @alt2)[0];

    if($DPnorm !=0){
    $vaf_normal=$altdepth/$DPnorm;
    }
    if($DPtumour !=0){
$vaf_tumour=$altdepth3/$DPtumour;
    }
    }

     ############
      if ($alt eq "G"){
    $altdepth1=$format_normal_snvs{"GU"};
    my @alt1=split(",",$altdepth1);
    $altdepth=(sort { $a <=> $b } @alt1)[0];
    $altdepth2=$format_tumour_snvs{"GU"};
    my @alt2=split(",",$altdepth2);
    $altdepth3=(sort { $a <=> $b } @alt2)[0];

    if($DPnorm !=0){
    $vaf_normal=$altdepth/$DPnorm;
    }
    if($DPtumour !=0){
$vaf_tumour=$altdepth3/$DPtumour;
    }
    }
     ############
      if ($alt eq "T"){
    $altdepth1=$format_normal_snvs{"TU"};
    my @alt1=split(",",$altdepth1);
    $altdepth=(sort { $a <=> $b } @alt1)[0];
    $altdepth2=$format_tumour_snvs{"TU"};
    my @alt2=split(",",$altdepth2);
    $altdepth3=(sort { $a <=> $b } @alt2)[0];

    if($DPnorm !=0){
    $vaf_normal=$altdepth/$DPnorm;
    }
    if($DPtumour !=0){
$vaf_tumour=$altdepth3/$DPtumour;
    }
  }
    ################
    if (length($alt) > 1 || length($ref) >1 ) {
    $altdepth1=$format_normal_snvs{"TAR"};
  #  print "$altdepth1\n";
    my @alt1=split(",",$altdepth1);
    $altdepth=(sort { $a <=> $b } @alt1)[0];
    $altdepth2=$format_tumour_snvs{"TAR"};
    my @alt2=split(",",$altdepth2);
    $altdepth3=(sort { $a <=> $b } @alt2)[0];

    if($DPnorm !=0){
    $vaf_normal=$altdepth/$DPnorm;
    }
    if($DPtumour !=0){
$vaf_tumour=$altdepth3/$DPtumour;
    }
}

  #  $vaf=$vaf*100;
	print OUT "$line\t";
print OUT "$QSS\t$vaf_normal\t$vaf_tumour\n";
	#expand the cancer field
}
}

  }

  close(OUT);
close(IN);
