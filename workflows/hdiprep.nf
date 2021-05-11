process hdiprep {

	tag "hdiprep"

	// export to HDIprep export folder
	publishDir "$params.pubDir", mode: 'copy',  pattern: "*processed.nii"
	// establish command and execution log outputs
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.sh',
		saveAs: {fn -> "${tag}.sh"}
	publishDir "${params.parsDir}", mode: 'copy', pattern: '.command.log',
		saveAs: {fn -> "${tag}.log"}

  input:
	tuple val (id), file (im), file (pars), file(pairs)

  output:
	tuple val (id), file ("$im"), file ("*processed.nii"), emit: prepout
	tuple path('.command.sh'), path('.command.log')


	when: params.idxStart <= 1 && params.idxStop >= 1

  """
  python "/app/command_hdi_prep.py" --im "${im}" --ibds "${pairs} "--pars "${pars}" --out_dir .
  """

}
