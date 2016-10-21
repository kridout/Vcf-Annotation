#!/bin/bash
#HICF2 
#cancer annotation pipeline with Strelka indels and snvs files
#Pavlos Antoniou

snvs=$1
indels=$2
vcf_folder=$3
vcf_folder="$vcf_folder"
casename=$4
databases=$5

# This data base needs to be updated with a reference to how we store it within dbe (there is also a refernce to it in the Dockerfile)!!!!
REF=/opt/databiology/apps/vcf_annotation_app/hg19.fa
#REF=/dbe/dbe_genomes/ucsc_gb/hg19/hg19.fa.gz

PERL5LIB=${PERL5LIB}:/scratch/src/bioperl-1.6.1
PERL5LIB=${PERL5LIB}:/scratch/src/ensembl/modules
PERL5LIB=${PERL5LIB}:/scratch/src/ensembl-compara/modules
PERL5LIB=${PERL5LIB}:/scratch/src/ensembl-variation/modules
PERL5LIB=${PERL5LIB}:/scratch/src/ensembl-funcgen/modules
export PERL5LIB

shopt -s nullglob
cosmic_cod=/opt/databiology/apps/vcf_annotation_app/CosmicCodingMuts.vcf


#All output goes in the /scratch/results directory so we add the annotation and vep_split as underscore tags.
output_folder=/scratch/results/annotation_
split_folder="$output_folder"vep_split_


#Calculate VAF from Strelka Tiers and print it as an extra column
perl calculate_vaf_strelka.pl "$vcf_folder$snvs" "$vcf_folder$snvs"_vaf.vcf
perl calculate_vaf_strelka.pl "$vcf_folder$indels" "$vcf_folder$indels"_vaf.vcf

#Add cosmic annotation to VCF files as extra columns. Remove extra columns of variants not having COSMIC annotation (failed to annotate)
intersectBed -loj -header -a "$vcf_folder$snvs"_vaf.vcf -b  $cosmic_cod > "$vcf_folder$snvs"_vaf_cosmic1.vcf
perl remove_failed_cosmic.pl "$vcf_folder$snvs"_vaf_cosmic1.vcf "$vcf_folder$snvs"_vaf_cosmic.vcf
rm "$vcf_folder$snvs"_vaf_cosmic1.vcf
rm "$vcf_folder$snvs"_vaf.vcf
intersectBed -loj -header -a "$vcf_folder$indels"_vaf.vcf -b  $cosmic_cod > "$vcf_folder$indels"_vaf_cosmic1.vcf
perl remove_failed_cosmic.pl "$vcf_folder$indels"_vaf_cosmic1.vcf "$vcf_folder$indels"_vaf_cosmic.vcf
rm "$vcf_folder$indels"_vaf_cosmic1.vcf
rm "$vcf_folder$indels"_vaf.vcf

grep -v "^#" "$vcf_folder$indels"_vaf_cosmic.vcf> "$vcf_folder$indels"_vaf_cosmic_noheader.vcf
cat "$vcf_folder$snvs"_vaf_cosmic.vcf "$vcf_folder$indels"_vaf_cosmic_noheader.vcf > "$vcf_folder$casename"_merged.vcf
rm "$vcf_folder$indels"_vaf_cosmic_noheader.vcf

vcf-sort  "$vcf_folder$casename"_merged.vcf > "$vcf_folder$casename"_sorted.vcf


##VEP annotation
perl /usr/local/bin/variant_effect_predictor.pl -i "$vcf_folder/$casename"_sorted.vcf --variant_class --sift b --polyphen b --gene_phenotype --regulatory --numbers --symbol --canonical --protein --gmaf --maf_exac --maf_1kg maf_esp --pubmed --plugin CADD --cache --port 3337 --pick --vcf -o "$output_folder$casename"_VEP.vcf --stats_file  "$output_folder$casename"_VEP.html --merged --force_overwrite  -fork 5

echo "Finished VEP annotation. Adding additional non-codnig information."

##ENCODE annotation
for db in `ls $databases`
do \
intersectBed -loj -header -a "$output_folder$casename"_VEP.vcf -b  $db > "$vcf_folder"All_VEP_ncdb1.vcf 
perl remove_faied_ncdb.pl "$vcf_folder"All_VEP_ncdb1.vcf "$output_folder$casename"_VEP_NC.vcf $db
rm "$vcf_folder"All_VEP_ncdb1.vcf
done

