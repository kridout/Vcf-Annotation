#!/bin/bash
#HICF2 
#cancer annotation pipeline with Strelka indels and snvs files
#Pavlos Antoniou

snvs=$1
indels=$2
vcf_folder=$3
casename=$4


REF=/Users/kridout/Desktop/Cancer/Annotation/DBE/Hg19.fa
PERL5LIB=${PERL5LIB}:${HOME}/src/bioperl-1.6.1
PERL5LIB=${PERL5LIB}:${HOME}/src/ensembl/modules
PERL5LIB=${PERL5LIB}:${HOME}/src/ensembl-compara/modules
PERL5LIB=${PERL5LIB}:${HOME}/src/ensembl-variation/modules
PERL5LIB=${PERL5LIB}:${HOME}/src/ensembl-funcgen/modules
export PERL5LIB

shopt -s nullglob
cosmic_cod=CosmicCodingMuts.vcf
#canonical=all_canonical_transcripts.txt

#Input VCF

output_folder="$vcf_folder/"annotation
mkdir -p $output_folder

split_folder="$output_folder/"vep_split
mkdir -p $split_folder

transcripts=$canonical

#Calculate VAF from Strelka Tiers and print it as an extra column
perl calculate_vaf_strelka.pl "$vcf_folder/$snvs" "$vcf_folder/$snvs"_vaf.vcf
perl calculate_vaf_strelka.pl "$vcf_folder/$indels" "$vcf_folder/$indels"_vaf.vcf

#Add cosmic annotation to VCF files as extra columns. Remove extra columns of variants not having COSMIC annotation (failed to annotate)
intersectBed -loj -header -a "$vcf_folder/$snvs"_vaf.vcf -b  $cosmic_cod > "$vcf_folder/$snvs"_vaf_cosmic1.vcf
perl remove_failed_cosmic.pl "$vcf_folder/$snvs"_vaf_cosmic1.vcf "$vcf_folder/$snvs"_vaf_cosmic.vcf
rm "$vcf_folder/$snvs"_vaf_cosmic1.vcf
rm "$vcf_folder/$snvs"_vaf.vcf
intersectBed -loj -header -a "$vcf_folder/$indels"_vaf.vcf -b  $cosmic_cod > "$vcf_folder/$indels"_vaf_cosmic1.vcf
perl remove_failed_cosmic.pl "$vcf_folder/$indels"_vaf_cosmic1.vcf "$vcf_folder/$indels"_vaf_cosmic.vcf
rm "$vcf_folder/$indels"_vaf_cosmic1.vcf
rm "$vcf_folder/$indels"_vaf.vcf

grep -v "^#" "$vcf_folder/$indels"_vaf_cosmic.vcf> "$vcf_folder/$indels"_vaf_cosmic_noheader.vcf
cat "$vcf_folder/$snvs"_vaf_cosmic.vcf "$vcf_folder/$indels"_vaf_cosmic_noheader.vcf > "$vcf_folder/$casename"_merged.vcf
rm "$vcf_folder/$indels"_vaf_cosmic_noheader.vcf

/Users/kridout/Desktop/Software/vcftools_0.1.13/bin/vcf-sort  "$vcf_folder/$casename"_merged.vcf > "$vcf_folder/$casename"_sorted.vcf


##VEP annotation
perl /Users/kridout/Desktop/Software/ensembl-tools-release-85/scripts/variant_effect_predictor/variant_effect_predictor.pl -i "$vcf_folder/$casename"_sorted.vcf --variant_class --sift b --polyphen b --gene_phenotype --regulatory --numbers --symbol --canonical --protein --gmaf --maf_exac --maf_1kg maf_esp --pubmed --plugin CADD --cache --port 3337 --pick --vcf -o "$output_folder/$casename"_VEP.vcf --stats_file  "$output_folder/$casename"_VEP.html --merged --force_overwrite  -fork 5

echo "Finished VEP annotation."

