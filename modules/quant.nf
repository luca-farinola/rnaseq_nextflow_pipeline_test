nextflow.enable.dsl=2

process QUANT {

    container "community.wave.seqera.io/library/subread:2.1.1--0ac4d7e46cd0c5d7"
    publishDir params.outdir_quant, mode: 'rellink'

    label 'quant'

    errorStrategy 'finish'

    input:
    path bam_files
    path gtf_file

    output:
    path "gene_counts.txt", emit: counts

    script:  
    """
    echo "[QUANT] Starting feature counting..."
    echo "[QUANT] Processing \$(echo ${bam_files} | wc -w) BAM files with ${task.cpus} cores"
    featureCounts -p --countReadPairs \
    -a "${gtf_file}" \
    -o gene_counts.txt \
    -t exon \
    -g gene_id \
    -s 0 \
    -T ${task.cpus} \
    ${bam_files}
    echo "[QUANT] ✅ Feature counting complete"
    """
}