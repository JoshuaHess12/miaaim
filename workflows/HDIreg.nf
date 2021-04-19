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

	when: idxStop <= 1

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
	publishDir "${paths[2]}/$m_id", mode: 'copy', pattern: "*.nii"

	input:
	tuple( val(m_id), file(m_proc), file(m_og), val(m_ord), val(f_id), file(f_proc), file(f_og), val(f_ord) ) from all_reg

	output:
//	tuple val("$m_id"), val("$f_id"), file ("*.nii") into s3out
	tuple val("$m_id"), val("$f_id") into s3out
//	tuple val("$m_id"), val("$f_id") into s3out

	when: idxStop <= 2

	"""
	python3 "/Users/joshuahess/Desktop/miaaim/HDIreg/HDIreg/command_elastix.py" --fixed "${f_proc}" --moving "${m_proc}" --out_dir "/Users/joshuahess/Desktop/MIAAIM_nf/HDIreg" --p "/Users/joshuahess/Desktop/MIAAIM_nf/HDIreg/aMI_affine.txt"
	"""
}
