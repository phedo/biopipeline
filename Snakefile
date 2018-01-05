configfile: "input/family5/S13/config.json"

rule all:
	input: config["output_folder"] + "freq_parser/rare_variations/" + config["read_name"] + ".result.txt"

rule trimmomatic:
	input: config["input_folder"] + config["read_name"] + "1.fastq", config["input_folder"] + config["read_name"]+"2.fastq"
	output: config["output_folder"] + "trimmomatic/" + config["read_name"] + ".trimmed.1.fastq", config["output_folder"] + "trimmomatic/" + config["read_name"]+".unpaired.1.fastq", config["output_folder"] + "trimmomatic/" + config["read_name"] + ".trimmed.2.fastq", config["output_folder"] + "trimmomatic/" + config["read_name"]+".unpaired.2.fastq"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/trimmomatic java -jar /usr/share/java/trimmomatic.jar PE -phred33 {input} {output} CROP:180 HEADCROP:20 SLIDINGWINDOW:6:22 MINLEN:30"

rule bwa: 	
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "trimmomatic/" + config["read_name"] + ".trimmed.1.fastq", config["output_folder"] + "trimmomatic/" + config["read_name"] + ".trimmed.2.fastq"
	output: config["output_folder"] + "bwa/" + config["read_name"] + ".sam"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/bwa {input} {output}"

rule samtools:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "bwa/" + config["read_name"] + ".sam"
	output: config["output_folder"] + "samtools/sam_to_bam/" + config["read_name"] + ".bam"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/samtools samtools view -bT {input} -o {output}"

rule samtools_sort:
	input: config["output_folder"] + "samtools/sam_to_bam/" + config["read_name"] + ".bam"
	output: config["output_folder"] + "samtools/sort/" + config["read_name"] + ".bam"	
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/samtools samtools sort -o {output} {input}"

rule picard_tools:
	input: config["output_folder"] + "samtools/sort/" + config["read_name"] + ".bam"
	output: config["output_folder"] + "picard-tools/" + config["read_name"] + ".bam", config["output_folder"] + "picard-tools/" + "metrics.txt"	
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/picard-tools picard-tools MarkDuplicates INPUT={input} OUTPUT={output[0]} METRICS_FILE={output[1]} || picard-tools BuildBamIndex INPUT={input}"

rule picard_tools_index:
	input: config["output_folder"] + "picard-tools/" + config["read_name"] + ".bam"
	output: config["output_folder"] + "picard-tools/" + config["read_name"] + ".bai"	
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/picard-tools picard-tools BuildBamIndex INPUT={input}"

rule gatk_rbq_analyze:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "picard-tools/" + config["read_name"] + ".bam", "reference/Homo_sapiens_assembly38.dbsnp138.vcf", "reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz", config["output_folder"] + "picard-tools/" + config["read_name"] + ".bai"
	output: config["output_folder"] + "gatk/rbq/" + "recal_data.table"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/gatk -T BaseRecalibrator -R {input[0]} -I {input[1]} -knownSites {input[2]} -knownSites {input[3]} -o {output}"

rule gatk_rbq_2pass:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "picard-tools/" + config["read_name"] + ".bam", "reference/Homo_sapiens_assembly38.dbsnp138.vcf", "reference/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz", config["output_folder"] + "gatk/rbq/" + "recal_data.table"
	output: config["output_folder"] + "gatk/rbq/" + "post_recal_data.table"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/gatk -T BaseRecalibrator -R {input[0]} -I {input[1]} -knownSites {input[2]} -knownSites {input[3]} -BQSR {input[4]} -o {output}"

rule gatk_rbq_plots:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "gatk/rbq/" + "recal_data.table", config["output_folder"] + "gatk/rbq/" + "post_recal_data.table"
	output: config["output_folder"] + "gatk/rbq/" + "recalibration_plots.pdf"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/gatk -T AnalyzeCovariates -R {input[0]} -before {input[1]} -after {input[2]} -plots {output}"

rule gatk_rbq_recalibrate:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "picard-tools/" + config["read_name"] + ".bam", config["output_folder"] + "gatk/rbq/" + "recal_data.table"
	output: config["output_folder"] + "gatk/rbq/" + config["read_name"] + ".bam"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/gatk -T PrintReads -R {input[0]} -I {input[1]} -BQSR {input[2]} -o {output}"

rule gatk_call_variants:
	input: "reference/Homo_sapiens_assembly38.fasta", config["output_folder"] + "gatk/rbq/" + config["read_name"] + ".bam"
	output: config["output_folder"] + "gatk/call_variants/" + config["read_name"] + "_raw_variants.vcf"	
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/gatk -R {input[0]} -T HaplotypeCaller -I {input[1]} -o {output}"

rule bedtools:
	input: "reference/trusight_cardiomyopathy_manifest_a_hg38.bed", config["output_folder"] + "gatk/call_variants/" + config["read_name"] + "_raw_variants.vcf"
	output: config["output_folder"] + "bedtools/" + config["read_name"] + "_variants.vcf"	
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/bedtools /bin/sh scripts/bedtools.sh {input} {output}"

rule snpeff:
	input: config["output_folder"] + "bedtools/" + config["read_name"] + "_variants.vcf"
	output: config["output_folder"] + "snpeff/" + config["read_name"] + ".ann.vcf"
	params: summary = config["output_folder"] + "snpeff/snpEff_summary.html"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/snpeff GRCh38.p7.RefSeq {input} > {output} -s {params[summary]}"

rule annotations_parser:
	input: config["output_folder"] + "snpeff/" + config["read_name"] + ".ann.vcf"
	output: config["output_folder"] + "ann_parser/LAH/" + config["read_name"] + ".ann.lah.vcf", config["output_folder"] + "ann_parser/no_LAH/" + config["read_name"] + ".ann.nolah.vcf"
	shell: "docker run -it --rm -v $(pwd):/root/source -w=\"/root/source\" ubuntu:16.04 /bin/sh scripts/annotation_parser.sh {input} {output}"

rule annovar:
	input: config["output_folder"] + "ann_parser/LAH/" + config["read_name"] + ".ann.lah.vcf"
	output: config["output_folder"] + "annovar/" + config["read_name"] + ".annovar.hg38_multianno.txt"
	params: name = config["output_folder"] + "annovar/" + config["read_name"] + ".annovar"
	shell: "docker run -it --rm -v $(pwd):/root/source phedo/annovar table_annovar.pl {input} reference/humandb/ -buildver hg38 -out {params.name} -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a -operation gx,r,f,f,f -nastring . -vcfinput"

rule frequences_parser:
	input: config["output_folder"] + "annovar/" + config["read_name"] + ".annovar.hg38_multianno.txt"
	output: config["output_folder"] + "freq_parser/rare_variations/" + config["read_name"] + ".result.txt", config["output_folder"] + "freq_parser/common_variations/" + config["read_name"] + ".txt"
	params: lev = "0.05"
	shell: "docker run -it --rm -v $(pwd):/root/source -w='/root/source' ubuntu:16.04 /bin/sh scripts/frequences_parser.sh {input} {params.lev} {output}"
