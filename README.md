## Synopsis

Annotation tool for SNVs and InDels combining VEP and cosmic coding annotations with non-coding databases from the ENCODE project. Requires VCF input and databases in BED format.

## Install

Required Software:
VEP with CADD plugin and associated databases

Required databases in source directory:
COSMIC - CosmicCodingMuts.vcf

## Run

HICF2_cancer_somatic_annotation.sh [input snv vcf] [input indel vcf] [vcf folder] [basename/casename] [folder of databases to overlap (bed)]

   