#!/usr/bin/env nextflow

// enable new DSL to separate the definition of a process from its invocation
nextflow.enable.dsl=2

//import modules
import org.yaml.snakeyaml.Yaml

//MIAAIM registration pipeline steps
miaaim_steps = ["RawInput",		// Step 0
	    "hdiprep",							// Step 1
			"HDIreg"]      					// Step 2

// identify starting and stopping indices
idxStart = miaaim_steps.indexOf( params.startAt )
idxStop = miaaim_steps.indexOf( params.stopAt )

// set start and stop indices
params.idxStart  = idxStart
params.idxStop   = idxStop

//define subdirectories
paths = miaaim_steps.collect{ "${params.in}/$it" }
//println paths

// Import individual modules and add output directories to parameters
include {hdiprep}   from './workflows/hdiprep'     addParams(pubDir: paths[1])
// include {hdireg}   from './workflows/HDIreg'     addParams(pubDir: paths[2])

//get yaml parameters for the prep module -- step 0 input
s0in = Channel.fromPath("${params.in}/hdiprep/*.yaml")

// Define the primary mcmicro workflow
workflow {
    hdiprep(s0in)
}
