#!/usr/bin/env nextflow

// attach dropbox url to the name of prototype
switch( params.proto ) {
    case "prototype-001":
	url = 'https://www.dropbox.com/sh/g1daajcl8o1mem1/AAB3zZjaQQK5eAOKT43U8zeZa?dl=0'
	break
    case "prototype-002":
	url = 'https://www.dropbox.com/sh/qnyzf4jiqqfqd3l/AABvx6PPLdB5fIB23sxR7aUTa?dl=0'
	break
    default:
	error "Please enter a valid prototype image name"
}

// create channel from prototype image name
nm = Channel.from( params.proto )

// download data from dropbox
process downloadPrototype {
	// export data to prototype folder
    publishDir "${params.out}/${params.proto}", mode: 'copy'

    input:
	val i from nm

    output:
	path '**' into test

    shell:
    '''
    curl "!{url}" -o input.zip -J -L -k
    '''
}

// unzip input folder from dropbox
process unzipInput {
	// unzip input folder to get contents for MIAAIM pipeline
    publishDir "${params.out}/${params.proto}/input", mode: 'copy'

    input:
	path i from test

    output:
	file '*' into out

    shell:
    '''
    bsdtar -xf "!{i}" && rm  "!{i}"
    '''
}
