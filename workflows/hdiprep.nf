process hdiprep {
	// export to HDIprep export folder
	publishDir "$params.pubDir", mode: 'copy',  pattern: "*processed.nii"

  input:
	tuple val (id), file (im), file (pars)

  output:
	tuple val (id), file ("$im"), file ("*processed.nii")


	when: params.idxStart <= 1 && params.idxStop >= 1

  """
  python "/app/command_hdi_prep.py" --im "${im}" --pars "${pars}" --out_dir .
  """

}
