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

//define step 0
process RawInput {

  input:
  file (x) from s0in

  output:
	tuple file ("$x"), stdout into s0out

	when: idxStart >= 0

	"""
	python3 "/Users/joshuahess/Desktop/Methods High DImensional Imaging/HDIprep/HDIprep/nf-parse-og-yaml.py" --path_to_yaml "${x}"
	"""

}


//define step 1
process HDIprep {
	publishDir "${paths[1]}/HDIprep", mode: 'copy',  pattern: "*.nii"
	publishDir "${paths[1]}/HDIprep", mode: 'copy',  pattern: "*.csv"

  input:
  tuple file (x), og_im from s0out

  output:
	tuple og_im, file ("*.nii") into s1out
  //tuple val("*.nii"), val x into s1out
	//file ("*.nii") into s1out
	//file "$x" into orig_ch

	when: idxStop >= 1

  """
  python3 "/Users/joshuahess/Desktop/Methods High DImensional Imaging/HDIprep/HDIprep/command_hdi_prep.py" --path_to_yaml "${x}" --out_dir .
  """
}


//s1out.print { it }
results = s1out.map { it -> [ "${it[0]}", file(it[1]) ] }
results.print {it}
//test = results.toList()




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
order_yaml.RegistrationOrder.eachWithIndex { item, index -> prop_order.add( [ "$item", index ] ) }
//create a channel from the propagation order
prop_order = Channel.from( tuple (prop_order) )
prop_order.print { it }
//s1out.print { it }

//combine s1out with propagation order
//results.join(prop_order, remainder: true, by: 0).println()

//a = Channel.from ([["test",1],["now",3]])
//b = Channel.from ([["test",2],["now",4]])
//a.join(b, remainder: true, by: 0).println()


//create list of size of registration parameters  (n-1 images) (-1 for 0 indexing purposes)
range = 0..order_yaml.RegistrationParameters.size()-1
//create empty map to store registration order
reg_order = [:]
//add values to the map to indicate registration fixed and moving images propagating with order
range.each( { reg_order[it] = [order_yaml.RegistrationOrder[it], order_yaml.RegistrationOrder[it+1]] } )
//println reg_order


//define step 2
//process HDIreg {
//	publishDir "${paths[2]}/HDIreg", mode: 'copy',  pattern: "*.txt"

//  input:
//  tuple file (og_im), file (proc_im) from s1out

//  output:
//	tuple og_im, file ("*.txt") into s1out
  //tuple val("*.nii"), val x into s1out
	//file ("*.nii") into s1out
	//file "$x" into orig_ch

//	when: idxStop >= 2

//  """
//  python3 "/Users/joshuahess/Desktop/Methods High DImensional Imaging/HDIprep/HDIprep/command_hdi_prep.py" --path_to_yaml "${x}" --out_dir .
//  """
//}
