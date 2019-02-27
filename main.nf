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
  -profile		Hardware config to use

    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Show help message
if (params.help){
	helpMessage()
	exit 0
}

// Set scripts and files location:


// Validate inputs

// Header log info
log.info """=======================================================
                                            
    ___  ___          __   __   __   ___     
    |__| |__  \\/  __ /  ` /  \\ |__) |__        
    |__| |    /\\     \\__, \\__/ |  \\ |___    
                                               

annotation-delivery v${params.version}
======================================================="""
def summary = [:]
summary['Pipeline Name']  = 'annotation-delivery'
summary['Pipeline Version'] = params.version
summary['Run Name']     = custom_runName ?: workflow.runName
summary['Fasta Ref']    = Genome
summary['Genome']		= params.genome
summary['Annotation']	= params.annotation
summary['Max Memory']   = params.max_memory
summary['Max CPUs']     = params.max_cpus
summary['Max Time']     = params.max_time
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
    .fromPath()
    .set()


/*
 * STEP 1 - 
 */

 process  {
	
	tag "${}"
	publishDir "${params.outdir}/", mode: 'copy'
	
	input:

	
	output:
	
	script:
	"""
	
	"""
	
}


workflow.onComplete {

	log.info "========================================="
	log.info "Duration:             $workflow.duration"
	log.info "========================================="
        
}