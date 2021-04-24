process elastix {

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

	tag "hdireg-transformix"

	publishDir "$params.pubDir/transformix", mode: 'copy', pattern: "*result.nii"
	// establish command and execution log outputs
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.sh',
		saveAs: {fn -> "${tag}.sh"}
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.log',
		saveAs: {fn -> "${tag}.log"}
		
	input:
	tuple( val (m_id), val (m_ord), path(res), val (m_id_Reapeat), path(m_og), path(yaml), val(pars) )

	output:
	tuple path("${m_og}"), path("${res}"), path ("*result.nii"), emit: transout
	tuple path('.command.sh'), path('.command.log')

	when: params.idxStart <= 2 && params.idxStop >=2 && params.transformix

	"""
	python "/app/command_transformix.py" --in_im "${m_og}" --out_dir . ${pars}
	"""
}

// helper function to extract image ID from filename
def getID (f, delim, i) {
		tuple( f.getBaseName().toString().split(delim).head(), f, i )
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

// define primary hdireg workflow
workflow hdireg {
  take:
	rawin
	prepout
	elastixpars
	transformixpars

  main:

	// get the yaml file for global registration parameters
	// globreg_par = file("${params.in}/*.yaml")
	// read the yaml file -- currently read only single yaml file in the folder!
	// order_yaml = new FileInputStream(new File( globreg_par[0].toString() ))
	// get map from yaml
	// order_yaml = new Yaml().load(order_yaml)
	//println order_yaml

	// create empty tuple
	// prop_order = []
	// update the list with index and raw image
	//order_yaml.RegistrationOrder.eachWithIndex { item, index -> prop_order.add( [ file(item), index ] ) }

	//create a channel from the propagation order
	//prop_order = Channel.from( tuple (prop_order) )
	if( params.idxStart <= 2 && params.idxStop >=2 ) {

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

		rawin.join(prepout, remainder: true, by: 0).join(id_img).map{ a,b,c,d,e,f -> removePortions(a,b,c,d,e,f) }.set {test}

		//test.toSortedList( { a, b -> a[2] <=> b[2] } ).flatten().collate( 4 ).collate( 2, 1, false).map{ f ->
		//	mergeList( f ) }.set {tmp}

		test.toSortedList( { a, b -> a[2] <=> b[2] } ).flatten().collate( 4 ).collate( 2, 1, false).mix(pars).map{ f ->
			mergeList( f ) }.set {tmp}
		tmp.view()


		// register fixed and moving image pairs
		//elastix(tmp)

		//elastix.out.view()
		// organize the results
		//elastix.out.toSortedList( { a, b -> a[0] <=> b[0] } ).set { test }

		//elastix.out.map{ f -> mergeList( f ) }.set{ bb }

		// flatten the array and capture necessary components

		//bb.flatten().take(2).mix( bb.flatten().last() ).toList().set { out }

		// run transformix on the elastix output
		//transformix(elastix.out)
		//bb.view()
	}
	else {
		tmp = "no registration performed"
	}
	emit:
	tmp
}
