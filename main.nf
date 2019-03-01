#!/usr/bin/env nextflow
/*
========================================================================================
                    IKMB | Genome Annotation Delivery Pipeline
========================================================================================
 Genome Annotation Delivery Pipeline. Started 2019-02-27.
 #### Homepage / Documentation
 https://github.com/MontseTor/annotation-delivery
 #### Authors
 M. Torres-Oliva <m.torres@ikmb.uni-kiel.de> - https://github.com/MontseTor>
----------------------------------------------------------------------------------------
*/

def helpMessage() {
  log.info"""
  =================================================================
   IKMB | Genome Annotation Delivery Pipeline | v${params.version}
  =================================================================
  Usage:

  The typical command for running the pipeline is as follows:

  nextflow run main.nf --genome 'Genome.fasta' --annotation 'annotation.gff3' -c config/slurm.config --nthreads 3

  Mandatory arguments:
  --genome		Genome reference
  --annotation  Annotation file in GFF3 format
  --IDtrunk     Prefix for all genes (e.g. "DMELv1")
  -profile		Hardware config to use

    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help message
//if (params.help){
//	helpMessage()
//	exit 0
//}

// Set scripts and files location:


// Validate inputs
IDtrunk = params.IDtrunk

if ( !IDtrunk) {
    exit 1, "ID trunk missing"
}

if (params.genome) {
    Genome = file(params.genome)
    if( !Genome.exists() ) exit 1, "Genome file not found: ${Genome}"
}

if (params.annotation) {
    Annotation = file(params.annotation)
    if (!Annotation.exists() ) exit 1, "Annotation file not found: ${Annotation}"
}

// Header log info
log.info """=======================================================
                                            
    ___  ___          __   __   __   ___     
    |__| |__  \\/  __ /  ` /  \\ |__) |__        
    |__| |    /\\     \\__, \\__/ |  \\ |___    
                                               

NF-hints v${params.version}
======================================================="""
def summary = [:]
summary['Fasta Ref']    = Genome
summary['Annotation']	= Annotation
summary['ID prefix']    = IDtrunk
summary['Output dir']   = params.outdir
summary['Working dir']  = workflow.workDir
summary['Container Engine'] = workflow.containerEngine
if(workflow.containerEngine) summary['Container'] = workflow.container
summary['Current home']   = "$HOME"
summary['Current user']   = "$USER"
summary['Current path']   = "$PWD"
summary['Working dir']    = workflow.workDir
summary['Script dir']     = workflow.projectDir
summary['Config Profile'] = workflow.profile
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "========================================="



// Check that Nextflow version is up to date enough
// try / throw / catch works for NF versions < 0.25 when this was implemented
try {
	if( ! nextflow.version.matches(">= $params.nf_required_version") ){
		throw GroovyException('Nextflow version too old')
	}
} catch (all) {
	log.error "====================================================\n" +
		"  Nextflow version $params.nf_required_version required! You are running v$workflow.nextflow.version.\n" +
		"  Pipeline execution will continue, but things may break.\n" +
		"  Please run `nextflow self-update` to update Nextflow.\n" +
		"============================================================"
}

Channel
    .fromPath(Annotation)
    .set {initial_gff}


/*
 * STEP 1 - Generate Stable IDs
 */

 process StableIDs {
	
	publishDir "${params.outdir}/StableID", mode: 'copy', saveAs: { filename -> "${IDtrunk}_annotation.gff3"}
	
    input:
    file initial_gff
	
	output:
	file annotation_out into annotation2prots, annotation2cds

	script:
	"""
	gff3_sq_create_stable_id.pl --gff $initial_gff --id_trunk $IDtrunk > annotation_out
	"""
	
}

/*
 * STEP 2 - Generate Proteins file
 */

process GetProteins {
    publishDir "${params.outdir}/StableID", mode: 'copy', saveAs: { filename -> "${IDtrunk}_proteins.fa"}

    input: 
    file annotation2prots

    output:
    file proteins_output into proteins2length, proteins2busco

    script:
    proteins_output = "proteins_out.fa"
    """
    gff3_sp_extract_sequences.pl -g=$annotation2prots -f=$Genome -p -o=proteins_out -t='CDS'
    """
}

/*
 * STEP 3 - Proteins' Length
 */

process Length {
    publishDir "${params.outdir}/Length", mode: 'copy', saveAs: { filename -> "${IDtrunk}_protein_length.txt"}

    input:
    file proteins2length

    output:
    file proteins_length

    script:
    """
    pip install biopython
    fasta_length.py $proteins2length > proteins_length
    """
}

/*
 * STEP 4 - Generate CDS file
 */

process GetCDS {
    publishDir "${params.outdir}/StableID", mode: 'copy', saveAs: { filename -> "${IDtrunk}_cds.fa"}

    input: 
    file annotation2cds

    output:
    file cds_output

    script:
    cds_output = "cds_out.fa"
    """
    gff3_sp_extract_sequences.pl -g=$annotation2cds -f=$Genome -o=cds_out -t='CDS'
    """
}

/*
 * STEP 5 - Busco
 */

process Busco{
    publishDir "${params.outdir}/Busco", mode: 'copy', saveAs: { filename -> "${IDtrunk}_busco.out"}

    input: 
    file proteins2busco

    output:
    file busco_out

    script:
    busco_out = "busco_out_dir/short_summary_busco_out_dir.txt"
    
    """
    run_BUSCO.py -i $proteins2busco -c 10 -o busco_out_dir -l $params.busco_db -m prot -sp $params.augustus_sp
    """
}


workflow.onComplete {

	log.info "========================================="
	log.info "Duration:             $workflow.duration"
	log.info "========================================="
        
}