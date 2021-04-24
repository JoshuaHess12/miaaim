#!/usr/bin/env nextflow

// enable new DSL to separate the definition of a process from its invocation
nextflow.enable.dsl=2

// import external modules
import org.yaml.snakeyaml.Yaml

// miaaim pipeline steps
miaaim_steps = ["input",			// raw input
	    					"hdiprep",		// preparation
								"hdireg"]     // registration

// identify starting and stopping indices
params.idxStart = miaaim_steps.indexOf( params.startAt )
params.idxStop = miaaim_steps.indexOf( params.stopAt )

// define subdirectories
paths = miaaim_steps.collect{ "${params.in}/$it" }
// create parameter output directory
params.parsDir = file("${params.in}/docs")

// set default input parameters
params.fixedImage = 'fixed.ext'
params.movingImage = 'moving.ext'
params.fixedPars = 'fixed'
params.movingPars = 'moving'
params.elastixPars = "--p MI_affine.txt MI_affine.txt"
params.transformix = false
params.transformixPars = "--tps TransformParameters.0.txt TransformParameters.1.txt"

// check for user input and capture errors
if( params.idxStop >= 2 && params.fixedImage == '' )
    error "please provide a fixed image for miaaim registration with --fixed-image"
if( params.idxStop >= 2 && params.movingImage == '' )
    error "please provide a moving image for miaaim registration with --moving-image"
//if( params.idxStop >= 2 && params.elastixPars == '' )
//		 error "please provide parameters for miaaim registration with --elastixPars"
//if( params.idxStop >= 2 && params.elastixPars == '' )
//		 error "please provide parameters for transforming images with --transformixPars"

// import individual workflows and add output directories to parameters
include {hdiprep}   			from './workflows/hdiprep'     addParams(pubDir: paths[1])
include {elastix}   				from './workflows/hdireg'      addParams(pubDir: paths[2])
include {transformix}   				from './workflows/hdireg'      addParams(pubDir: paths[2])

// helper function to extract image ID from filename
def getID (f, delim, i) {
		tuple( f.getBaseName().toString().split(delim).head(), f, i )
}

// define function for parsing elastix parameter files since they are not converted to processes directly
def addPath (str, delim) {
	// split string
	splt = str.split(delim)
	// create list to populate
	out = splt[0]
	// get only the parameter inputs
	ps = splt[1..-1]
	for( def p : ps ) {
			p = file(paths[0] + "/" + p)
			/////////TRY TO STREAM FILE SO THAT CHANGES ARE TRACKED?????
		//	p.readLines()
			out = out + " " + p
	}
	//return the output string
	out
}

// define function for parsing elastix parameter files since they are not converted to processes directly
def addPath2 (str, delim) {
	// split string
	splt = str.split(delim)
	// create list to populate
	out = splt[0]
	// get only the parameter inputs
	ps = splt[1..-1]
	for( def p : ps ) {
			p = file(paths[2] + "/elastix/" + p)
			/////////TRY TO STREAM FILE SO THAT CHANGES ARE TRACKED?????
		//	p.readLines()
			out = out + " " + p
	}
	//return the output string
	out
}


// helper function to extract image ID from filename
def getOrder (f, delim, i) {
		tuple( f.getBaseName().toString().split(delim).head(), i )
}

// helper function to extract image ID from filename
def removePortions (a,b,c,d,e,f) {
		tuple( a,b,e,f )
}

// helper function to flatten list and convert to tuple
def mergeList ( l ) {
	tuple( l.flatten() )
}



// create channel with images and parameter pairs (collate to pairs of 2)
Channel.from( file("${params.in}/input/${params.fixedImage}"), file("${params.in}/input/${params.fixedPars}"),
 file("${params.in}/input/${params.movingImage}"), file("${params.in}/input/${params.movingPars}")).collate(2).set {s0in}
// append image id
s0in = s0in.map{ f, i -> getID(f,'\\.', i) }
//s0in.view()

// get the elastix parameters
pars = Channel.from( tuple ( addPath(params.elastixPars,'\\ ') ) )
// get the transformix parameters
transpars = Channel.from( tuple( addPath2(params.transformixPars,'\\ ') ) )
transpars.view()

// initialize a list to store the fixed and moving image pairs in
prop_order = []
// create channel with the fixed and moving images
pair = ["${params.fixedImage}", "${params.movingImage}"]
//println pair
// append index
pair.eachWithIndex { item, index -> prop_order.add( [ file(item), index ] ) }
// create channel from the pair
prop_order = Channel.from( tuple (prop_order) )

// append the image base name ID to existing tuples
id_img = prop_order.map{ f, i -> getOrder(f,'\\.', i) }
//id_img.view()



// run primary miaaim workflow
workflow {
		// prepare images with the hdi-prep module
    hdiprep(s0in)

		s0in.join(hdiprep.out, remainder: true, by: 0).join(id_img).map{ a,b,c,d,e,f -> removePortions(a,b,c,d,e,f) }.set {test}

		test.toSortedList( { a, b -> a[3] <=> b[3] } ).flatten().collate( 4 ).collate( 2, 1, false).map{ f ->
			mergeList( f ) }.flatten().concat(pars).collect().set {tmp}
		//tmp.view()

		elastix(tmp)
		//elastix.out.flatten().take(3).concat( elastix.out.flatten().first() ).set {tuple ( testing ) }
		//testing.view()
		elastix.out.flatten().take(3).concat( elastix.out.flatten().first() ).toList().join(s0in).concat(transpars).collect().set {trans_in}
		trans_in.view()


		//hdiprep.out.view()
		//hdireg(s0in,hdiprep.out,pars)
		//hdireg.out.view()
		transformix(trans_in)
}

// report parameters parameters used -- taken from mcmicro end report and adapted
workflow.onComplete {
    // create directory for parameters
		file("${params.parsDir}").mkdirs()
    // Store parameters used
    file("${params.parsDir}/miaaim-pars.yml").withWriter{ out ->
	out.println "githubTag: $workflow.revision";
	out.println "githubCommit: $workflow.commitId";
	out.println "runName: $workflow.runName";
	out.println "sessionId: $workflow.sessionId";
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }
}
