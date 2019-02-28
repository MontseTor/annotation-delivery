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
nextflow run main.nf --genome 'Genome.fasta' --annotation 'Annotation.gff3' --IDtrunk 'IDprefix' --outdir 'Species_out' --busco_db 'path/to/db/' --augustus_sp 'species' 


