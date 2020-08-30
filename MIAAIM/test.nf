#!/usr/bin/env nextflow

//import modules
import org.yaml.snakeyaml.Yaml

//MIAAIM registration pipeline steps
miaaim_steps = ["RawInput",		// Step 0
	    "HDIprep",							// Step 1
			"HDIreg"]      					// Step 2

//identify starting and stopping indices
idxStart = miaaim_steps.indexOf( params.startAt )
idxStop = miaaim_steps.indexOf( params.stopAt )

//define subdirectories
paths = miaaim_steps.collect{ "${params.in}/$it" }
//println paths

//get yaml parameters for the prep module -- step 0 input
s0in = Channel.fromPath("${params.in}/HDIprep/*.yaml")



//define step 1
process HDIprep {
	publishDir "${paths[1]}/HDIprep", mode: 'copy',  pattern: "*.nii"

  input:
	file (x) from s0in

  output:
	tuple val ("$x.baseName"), file ("*.nii") into s1out
  //tuple val("*.nii"), val x into s1out
	//file ("*.nii") into s1out
	//file "$x" into orig_ch

	when: idxStop >= 1

  """
  python3 "/Users/joshuahess/Desktop/Methods High DImensional Imaging/HDIprep/HDIprep/command_hdi_prep.py" --path_to_yaml "${x}" --out_dir .
  """
}


//get the yaml file for global registration parameters
globreg_par = file("${paths[2]}/*.yaml")
//read the yaml file -- currently read only single yaml file in the folder!
order_yaml = new FileInputStream(new File( globreg_par[0].toString() ))
//get map from yaml
order_yaml = new Yaml().load(order_yaml)
//println order_yaml

//create empty tuple
prop_order = []
//update the list with index and raw image
order_yaml.RegistrationOrder.eachWithIndex { item, index -> prop_order.add( [ file(item), index ] ) }
//create a channel from the propagation order
prop_order = Channel.from( tuple (prop_order) )



//create a channel that has basenames with original filenames
//define step 1
process GetPropagationOrder {

  input:
	tuple file (x), ord from prop_order

  output:
	tuple val ("${x.baseName}"), "$x", ord into s2out
  //tuple val("*.nii"), val x into s1out
	//file ("*.nii") into s1out
	//file "$x" into orig_ch

	when: idxStop >= 1

  """
  """
}

//create channel for the propagating order of registration
prop_chan = s1out.join(s2out, remainder: true, by: 0)


prop_chan
	.branch {it ->
	zero: it[3] == 0
	one: it[3] == 1
	two: it[3] == 2
	}
	.set {result}

(cp_1,cp_2) = result.one.into(2)


//create a list from the results branches
test = [result.zero, cp_1, cp_2, result.two]
now_zero = [test[0],test[1]]
now_one = [test[2],test[3]]
//Merge the channels
all_reg = Channel.from([now_zero,now_one])
//all_reg.print()



//define step 1
process NowGo {

  input:
	tuple x,y from all_reg

  output:
	stdout into s3out
  //tuple val("*.nii"), val x into s1out
	//file ("*.nii") into s1out
	//file "$x" into orig_ch

	when: idxStop >= 1
	"""
  """
}

s3out.print()


//a = prop_chan.toSortedList( { a, b -> a[3] <=> b[3] } )


//a = prop_chan.toSortedList( { a, b -> a[3] <=> b[3] } )
//queue1 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> a } }
//queue2 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> b } }
//queue3 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> c } }
//queue4 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> d } }

//a = queue1.collate(2)
//a.print()

//create list of size of registration parameters  (n-1 images) (-1 for 0 indexing purposes)
//range = 0..order_yaml.RegistrationParameters.size()-1
//a = Channel.from(order_yaml.RegistrationOrder)
//b = a.map{ it -> tuple(file(it).baseName,file(it)) }
//c = prop_chan.cross(b)
//d = c.collate( 2 )
//d.print()

//sort the channels by the 4th element (order of propagation)
//a = prop_chan.toSortedList( { a, b -> a[3] <=> b[3] } )



//result.zero.print()
//result.one.print()
//result.two.print()

//split the methods into queues
//queue1 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> a } }
//queue2 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> b } }
//queue3 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> c } }
//queue4 = a.map { allPairs -> allPairs.collect{ a, b, c, d -> d } }
//queue1.print()
