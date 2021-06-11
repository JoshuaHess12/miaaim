process elastix {

	// add tag to elastix process for tracking
	tag "hdireg-elastix"

	// define output patterns and directory
	publishDir "$params.pubDir/elastix", mode: 'copy', pattern: "*.txt"
	publishDir "$params.pubDir/elastix", mode: 'copy', pattern: "*.nii"

	// establish command and execution log outputs
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.sh',
		saveAs: {fn -> "${tag}.sh"}
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.log',
		saveAs: {fn -> "${tag}.log"}

	input:
	tuple( val(m_id), path(m_in), path(m_proc), val(m_ord), val(f_id), path(f_in), path(f_proc), val(f_ord), val(pars) )

	output:
	tuple val(m_id), val(m_ord), file ("*.nii"), file ("*.txt"), emit: regout
	tuple path('.command.sh'), path('.command.log')

	when: params.idxStart <= 2 && params.idxStop >=2

	"""
	python "/app/command_elastix.py" --fixed "${f_proc}" --moving "${m_proc}" --out_dir . ${pars}
	"""
}

process transformix {

	// add tag to transformix process for tracking
	tag "hdireg-transformix"

	publishDir "$params.pubDir/transformix", mode: 'copy', pattern: "${m_id}"+"_result*"
	// establish command and execution log outputs
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.sh',
		saveAs: {fn -> "${tag}.sh"}
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.log',
		saveAs: {fn -> "${tag}.log"}

	input:
	tuple( val (m_id), val (m_ord), path(res), val (m_id_Reapeat), path(m_og), path(yaml), val(pars) )

	output:
	tuple path("${m_og}"), path("${res}"), path ("${m_id}"+"_result*"), emit: transout
	tuple path('.command.sh'), path('.command.log')

	when: params.idxStart <= 2 && params.idxStop >=2 && params.transformix

	"""
	python "/app/command_transformix.py" --in_im "${m_og}" --out_dir . ${pars}
	"""
}

// helper function to extract image ID from filename
def removePortions (a,b,c,d,e,f) {
		tuple( a,b,e,f )
}
// helper function to flatten list and convert to tuple
def mergeList ( l ) {
	tuple( l.flatten() )
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
		if (file(params.pubDir + "/elastix/" + p).exists() ) {
			p = file(params.pubDir + "/elastix/" + p)
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

// define primary hdireg workflow
workflow hdireg {
  take:
	rawin
	prepout
	id_img
	pre_prep
	pars

  main:

	if( params.idxStart <= 2 && params.idxStop >=2 ) {


		// check for intermediates preprocessed images
		if (params.idxStart >= 1 && params.idxStop >= 2) {
			// if starting from elastix stage set intermediates as new input
			elx_pre = pre_prep
		}
		else {
			// join the output of hdiprep with the imageID and registration order block
			rawin.join(prepout, remainder: true, by: 0).join(id_img).map{
				a,b,c,d,e,f -> removePortions(a,b,c,d,e,f) }.set {elx_pre}
		}

		// collect data for proper input to elastix registration
		elx_pre.toSortedList( {
			a, b -> a[3] <=> b[3] } ).flatten().collate( 4 ).collate( 2, 1, false).map{ f ->
			mergeList( f ) }.flatten().concat(pars).collect().set {elxin}

		// run elastix image registration
		elastix(elxin)
		// get the transformix parameters if transformix is set to true
		if (params.transformix) {
			// parse the file
			transpars = Channel.from( tuple( addTransformixPath(params.transformixPars,'\\ ') ) )
		}
		else {
			// set the transpars to empty channel
			transpars = Channel.empty()
		}

		// extract elastix output and convert to transformix format
		elastix.out.regout.flatten().take(3).concat(
			elastix.out.regout.flatten().first() ).toList().join(rawin).concat(transpars).collect().set {tfmxin}

		// transform full images using elastix transform parameters
		transformix(tfmxin)
	}
}
