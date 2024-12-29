version 1.0

workflow norm_VCFs {

	meta {
	author: "Phuwanat Sakornsakolpat"
		email: "phuwanat.sak@mahidol.edu"
		description: "Split multi-allelic records"
	}

	 input {
		File vcf_file
	}

	call run_filtering { 
			input: vcf = vcf_file
	}

	output {
		File normed_vcf = run_filtering.out_file
		File normed_tbi = run_filtering.out_file_tbi
	}

}

task run_filtering {
	input {
		File vcf
		Int memSizeGB = 8
		Int threadCount = 2
		Int diskSizeGB = 8*round(size(vcf, "GB")) + 20
	String out_name = basename(vcf, ".vcf.gz")
	}
	
	command <<<
	bcftools norm -m -both -Oz -o ~{out_name}.normed.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.normed.vcf.gz
	>>>

	output {
		File out_file = select_first(glob("*.normed.vcf.gz"))
		File out_file_tbi = select_first(glob("*.normed.vcf.gz.tbi"))
	}

	runtime {
		memory: memSizeGB + " GB"
		cpu: threadCount
		disks: "local-disk " + diskSizeGB + " SSD"
		docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
		preemptible: 1
	}

}