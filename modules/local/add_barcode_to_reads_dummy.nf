// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ADD_BARCODE_TO_READS_DUMMY {
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir: 'add_barcode_to_reads', publish_id:'') }
    container "hukai916/sinto_xenial:0.2"

    input:
    tuple val(sample_name), path(read1_fastq), path(read2_fastq), path(barcode_fastq)
    val sample_count

    output:
    tuple val(sample_name), path("R1_${sample_name}_${sample_count}.barcoded.fastq.gz"), path("R2_${sample_name}_${sample_count}.barcoded.fastq.gz"), emit: reads_0
    tuple val(sample_name), path("R1_${sample_name}_${sample_count}.barcoded.fastq.gz"), path("R2_${sample_name}_${sample_count}.barcoded.fastq.gz"), path("barcode_${sample_name}_${sample_count}.fastq.gz"), emit: reads
    // Below are for GET_WHITELIST_BARCODE
    val sample_name, emit: sample_name
    path "barcode_${sample_name}_${sample_count}.fastq.gz", emit: barcode_fastq

    script:
    read1_barcoded_fastq = read1_fastq.name.split("\\.")[0..-3].join(".") + ".barcoded.fastq.gz"
    read2_barcoded_fastq = read2_fastq.name.split("\\.")[0..-3].join(".") + ".barcoded.fastq.gz"

    """
    # link original files to expected output
    ln -s $read1_fastq R1_${sample_name}_${sample_count}.barcoded.fastq.gz
    ln -s $read2_fastq R2_${sample_name}_${sample_count}.barcoded.fastq.gz
    ln -s $barcode_fastq barcode_${sample_name}_${sample_count}.fastq.gz # rename input is fine to nextflow
    """
}
