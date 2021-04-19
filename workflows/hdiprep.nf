process hdiprep {
	// export to HDIprep export folder
	publishDir "$params.pubDir/$x.baseName", mode: 'copy',  pattern: "*.nii"

  input:
	file (x)

  output:
	tuple val ("$x.baseName"), file ("*.nii")


	when: params.idxStop <= 1

  """
  python "/app/command_hdi_prep.py" --path_to_yaml "${x}" --out_dir .
  """

}
