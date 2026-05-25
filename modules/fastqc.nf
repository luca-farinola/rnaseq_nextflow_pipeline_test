nextflow.enable.dsl=2

process FASTQC {

    container "community.wave.seqera.io/library/fastqc:0.12.1--af7a5314d5015c29"
    
    label 'fastqc'

    input:
        tuple val(sample_id), path(read1), path(read2)

    output:
        path "*_fastqc.zip",  emit: zip
        path "*_fastqc.html", emit: html

    script:
    """
    echo "[FASTQC] Processing sample: ${sample_id}"
    fastqc -t ${task.cpus} ${read1} ${read2}
    echo "[FASTQC] ✅ Sample ${sample_id} complete"
    """

}



