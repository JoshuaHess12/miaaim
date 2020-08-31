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
	//publishDir "${paths[1]}/HDIprep", mode: 'copy',  pattern: "*.nii"
	publishDir "${paths[1]}/$x.baseName", mode: 'copy',  pattern: "*.nii"
	//publishDir "${paths[1]}/HDIprep", mode: 'copy',  pattern: "*.csv"

  input:
	tuple file (x), pars from s0out

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
//println prop_order



//create a channel that has basenames with original filenames
//define step 2a
process HDIregGetOrder{

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



////////////////////////////////////////////////////////////////////
//!!!!!!!!!!Temporary for now will only work with 3 images!!!!!!!!!!
//create channel for the propagating order of registration
prop_chan = s1out.join(s2out, remainder: true, by: 0)
//prop_chan.print()

prop_chan
	.branch {it ->
	zero: it[3] == 0
	one: it[3] == 1
	two: it[3] == 2
	}
	.set {result}

//result.zero.view { "$it is small" }
(cp_1,cp_2) = result.one.into(2)
//cp_1.view { "$it is small" }

//create a list from the results branches
now_zero = result.zero.flatten().concat( cp_1.flatten() ).toList()
now_one = cp_2.flatten().concat( result.two.flatten() ).toList()

//concatenate the lists to create registration pairs to input to HDIreg
all_reg = now_zero.concat( now_one )
//all_reg.view { "$it is small" }
//!!!!!!!!!!Temporary for now will only work with 3 images!!!!!!!!!!
////////////////////////////////////////////////////////////////////



//define step 2b
process HDIreg {
//	publishDir "${paths[2]}", mode: 'copy',  pattern: "*.txt"
	publishDir "${paths[2]}/$m_ord"+"-"+"$f_ord", mode: 'copy', pattern: "*.txt"

	input:
	tuple( val(m_id), file(m_proc), file(m_og), val(m_ord), val(f_id), file(f_proc), file(f_og), val(f_ord) ) from all_reg

	output:
	tuple val("$m_id"), val("$f_id"), file ("*.txt") into s3out
//	tuple val("$m_id"), val("$f_id") into s3aout
//	tuple val("$m_id"), val("$f_id") into s3out

	when: idxStop >= 2

	"""
	cat > filename.txt
	"""
//  """
//  python3 "/Users/joshuahess/Desktop/Methods High DImensional Imaging/HDIprep/HDIprep/command_hdi_prep.py" --path_to_yaml "${x}" --out_dir .
//  """
}
s3out.print()
