#!/usr/bin/env nextflow

// enable new DSL to separate the definition of a process from its invocation
nextflow.enable.dsl=2

// miaaim pipeline steps
miaaim_steps = ["input",			// raw input
		"hdiprep",			// preparation
		"hdireg"]     			// registration

// set default input parameters for workflows
params.startAt = 'input'
params.stopAt = 'hdireg'
params.fixedImage = 'fixed.tif'
params.movingImage = 'moving'
params.fixedPars = 'fixed.yaml'
params.movingPars = 'moving.yaml'
params.elastixPars = "--p MI_affine.txt"
params.transformix = false
params.transformixPars = "--tps TransformParameters.0.txt"

// identify starting and stopping indices
params.idxStart = miaaim_steps.indexOf( params.startAt )
params.idxStop = miaaim_steps.indexOf( params.stopAt )
if( params.idxStart < 0 )       			 error "Invalid starting step ${params.startAt}"
if( params.idxStop < 0 )        			 error "Invalid stopping step ${params.stopAt}"
if( params.idxStop < params.idxStart ) error "Stop step must follow valid start step"

// check for user input and capture errors
if( params.idxStop >= 2 && params.fixedImage == '' )
		 error "please provide a fixed image for miaaim registration with --fixed-image"
if( params.idxStop >= 2 && params.movingImage == '' )
		 error "please provide a moving image for miaaim registration with --moving-image"
if( params.idxStop >= 2 && params.elastixPars == '' )
		 error "please provide parameters for miaaim registration with --elastix-pars"
if( params.idxStop >= 2 && params.transformix && params.transformixPars == '' )
		 error "please provide parameter file names for transforming with --transformix-pars"

// define subdirectories for workflow processes
paths = miaaim_steps.collect{ "${params.in}/$it" }
// create parameter logging and command output directory
params.parsDir = file("${params.in}/docs")

// import individual workflows and add output directories to parameters
include {hdiprep}   			from './workflows/hdiprep'     addParams(pubDir: paths[1])
include {hdireg}   				from './workflows/hdireg'      addParams(pubDir: paths[2])

// define function blocks to use in the workflow
// these are all currently functions that allow pairwise registration to proceed
// helper functions for finding intermediate processed images prior to registration
findFiles  = { p, path, ife -> p ?
	      Channel.fromPath(path).ifEmpty(ife) : Channel.empty() }
// helper for finding moving image preprocessed
def movingPrecomp (f, delim) {
		tuple( f.getSimpleName().toString().split(delim).head(), file("${params.in}/input/${params.movingImage}"), f, 0 )
}
// helper for finding fixed image preprocessed
def fixedPrecomp (f, delim) {
		tuple( f.getSimpleName().toString().split(delim).head(), file("${params.in}/input/${params.fixedImage}"), f, 1 )
}

// helper function to extract image ID from filename
def getID (f, delim, i) {
		tuple( f.getBaseName().toString().split(delim).head(), f, i )
}


// define function for parsing elastix parameter files since they are not converted to processes directly
def addElastixPath (str, delim) {
	// create channel for elastix parser by initiating a list
	chanpar = []
	// split string
	splt = str.split(delim)
	// create list to populate
	out = splt[0]
	// get only the parameter inputs
	ps = splt[1..-1]
	for( def p : ps ) {
			p = file(paths[0] + "/" + p)
			out = out + " " + p
			chanpar.add(p)
	}
	//return the output string
	[out,chanpar]
}
// define function for parsing elastix parameter files since they are not converted to processes directly
def addTransformixPath (str, delim) {
	// split string
	splt = str.split(delim)
	// create list to populate
	out = splt[0]
	// get only the parameter inputs
	ps = splt[1..-1]
	for( def p : ps ) {
		// check if the object is a file path or string
		if (file(paths[2] + "/elastix/" + p).exists() ) {
			p = file(paths[2] + "/elastix/" + p)
			out = out + " " + p
		}
		else {
			// object is string
			out = out + " " + p
		}

	}
	// return the output string
	out
}
// helper function to extract image ID from filename
def getOrder (f, delim, i) {
		tuple( f.getBaseName().toString().split(delim).head(), i )
}

// block for parsing input images and parameter files
// here we are not yet including the intermediate processing steps
// create channel with images and parameter pairs (collate to pairs of 2)
Channel.from( file("${params.in}/input/${params.fixedImage}"), file("${params.in}/input/${params.fixedPars}"),
 file("${params.in}/input/${params.movingImage}"), file("${params.in}/input/${params.movingPars}")).collate(2).set {rawin}
// append image id
rawin = rawin.map{ f, i -> getID(f,'\\.', i) }
// check for paired files, such as imzml and ibd
// get the elastix parameters
pars = Channel.from( tuple ( addElastixPath(params.elastixPars,'\\ ')[0] ) )
// get the transformix parameters
transpars = Channel.from( tuple( addTransformixPath(params.transformixPars,'\\ ') ) )

// initialize a list to store the fixed and moving image pairs in
prop_order = []
// create channel with the fixed and moving images
pair = ["${params.movingImage}", "${params.fixedImage}"]
// append index
pair.eachWithIndex { item, index -> prop_order.add( [ file(item), index ] ) }
// create channel from the pair
prop_order = Channel.from( tuple (prop_order) )
// append the image base name ID to existing tuples
id_img = prop_order.map{ f, i -> getOrder(f,'\\.', i) }

// extract preprocessed images if starting step is after input and before registation
// note here that the default behavior currently requires preprocessed images to end
// with the "_processed" suffix. This is the default output from hdiprep and must be
// followed for users inputting their own preprocessed data
pre_moving = findFiles(params.idxStart == 2 && params.idxStop >= 2,
		      "${paths[1]}"+"/"+"${params.movingImage.split('\\.').head()}"+"_processed.nii",
		      {error "No processed moving image in ${paths[1]}"})
pre_moving.map{ f -> movingPrecomp(f,'\\_processed') }.set {a}
// get pre fixed image processed
pre_fixed = findFiles(params.idxStart == 2 && params.idxStop >= 2,
		      "${paths[1]}"+"/"+"${params.fixedImage.split('\\.').head()}"+"_processed.nii",
		      {error "No processed fixed image in ${paths[1]}"})
pre_fixed.map{ f -> fixedPrecomp(f,'\\_processed') }.set{b}
// concatenate the preprocessed files to match the tuple structure of hdiprep outputting
a.concat(b).set {pre_prep}

pre_prep.view()

// code block for primary MIAAIM workflow
// run primary miaaim workflow
workflow {
		// prepare images with the hdi-prep module
    hdiprep(rawin)
		// perform image registrations
		hdireg(rawin, hdiprep.out.prepout, id_img, pre_prep, pars, transpars)
}

// report parameters parameters used -- taken from mcmicro end report and adapted
workflow.onComplete {
    // create directory for parameters
		file("${params.parsDir}").mkdirs()
    // store parameters used
    file("${params.parsDir}/miaaim-pars.yml").withWriter{ out ->
	out.println "githubTag: $workflow.revision";
	out.println "githubCommit: $workflow.commitId";
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }
}
