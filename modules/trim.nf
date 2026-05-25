nextflow.enable.dsl=2

process TRIM_GALORE {

    container "community.wave.seqera.io/library/trim-galore:0.6.10--1bf8ca4e1967cd18"
    publishDir params.outdir_trim, mode: 'rellink'

    label 'trim'
  
    errorStrategy 'finish'

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("*_val_1.fq.gz"), path("*_val_2.fq.gz"), emit: trimmed_reads
    path "*_trimming_report.txt", emit: trimming_reports

    script:
    """
    echo "[TRIM_GALORE] Processing sample: ${sample_id}"
    trim_galore --fastqc --cores ${task.cpus} --paired ${read1} ${read2}
    echo "[TRIM_GALORE] ✅ Sample ${sample_id} complete"
    """
}