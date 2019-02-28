![](images/ikmb_bfx_logo.png)

# Annotation Delivery Pipeline
Prepare delivery directory of finished genome annotation projects

Start with:

```
module load IKMB Java/1.8.0 Nextflow/0.32.0 

# Include path to BILS modules to @INC: 

export PERL5LIB=$PERL5LIB:/ifs/data/nfs_share/sukmb415/git/GAAS/annotation/ 
```

Run like: 

```
nextflow run main.nf --genome 'Genome.fasta' --annotation 'Annotation.gff3' \
  --IDtrunk 'IDprefix' --outdir 'Species_out' \
  --busco_db 'path/to/db/' --augustus_sp 'species' 
```

Test with:

```
nextflow run main.nf --genome test/scaffold4_cov173.fa --annotation test/Dsargus_annotation_scaffold4_cov173.gff3 \
  --IDtrunk 'DSARv1' --outdir Dsargus_out \
  --busco_db $IKMBREF/busco/current/actinopterygii_odb9 --augustus_sp zebrafish
