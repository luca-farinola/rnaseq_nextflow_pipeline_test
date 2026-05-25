include { FASTQC     } from './modules/fastqc.nf'
include { TRIM_GALORE } from './modules/trim.nf'
include { STAR_ALIGN } from './modules/star_align.nf'
include { QUANT } from './modules/quant.nf'
include { MULTIQC } from './modules/multiqc.nf'

//------------------------------------------------------------------------
// SUBWORKFLOWS
//------------------------------------------------------------------------

workflow QC {
    take: 
        raw_ch
    
    main:
        log.info "QUALITY CONTROL"
        
        if( params.trim ) {
            log.info "├─ Trimming enabled: Running FastQC on trimmed reads..."
            
            TRIM_GALORE( raw_ch )
            
            trimmed_renamed = TRIM_GALORE.out.trimmed_reads.map { id, r1, r2 -> 
                tuple(id + "_trimmed", r1, r2)
            }
            QC_TRIMMED( trimmed_renamed )
            
            qc_reports = QC_TRIMMED.out.fastqc
            final_reads = TRIM_GALORE.out.trimmed_reads
        } else {
            log.info "├─ Trimming disabled: FastQC on raw reads..."
            
            raw_fastqc = FASTQC( raw_ch )
            qc_reports = raw_fastqc.zip
            final_reads = raw_ch
        }
        
        MULTIQC( qc_reports.collect() )
        
    emit:
        reads = final_reads
        qc_complete = MULTIQC.out.html
}

workflow QC_TRIMMED {
    take:
        trimmed_ch
    
    main:
        fastqc_trimmed = FASTQC( trimmed_ch )
    
    emit:
        fastqc = fastqc_trimmed.zip
}


workflow ALIGNMENT {
    take:
        reads_ch
        index_ch
    
    main:
        log.info ""
        log.info "GENOME ALIGNMENT"
        STAR_ALIGN( reads_ch, index_ch.collect() )
    
    emit:
        bam = STAR_ALIGN.out.bam
}

workflow QUANTIFICATION {
    take:
        bam_ch
        gtf_ch
    
    main:
        log.info ""
        log.info "QUANTIFICATION"
        QUANT( bam_ch.collect(), gtf_ch )
    
    emit:
        counts = QUANT.out.counts
}

//------------------------------------------------------------------------
// MAIN WORKFLOW
//------------------------------------------------------------------------

workflow {

    log.info ""
    log.info "╔════════════════════════════════════════════════╗"
    log.info "║   Bulk RNA-seq Preprocessing Pipeline         ║"
    log.info "╚════════════════════════════════════════════════╝"
    log.info ""

    // Parse samplesheet
    samples_map_ch = Channel
        .fromPath( params.samplesheet )
        .splitCsv(header: true)

    paired_ch = samples_map_ch.map { row -> tuple( row.sample_id, file(row.fastq_1), file(row.fastq_2) ) }

    // Run QC
    QC( paired_ch )

    // Exit if only QC requested
    if( params.onlyqc ) {
        log.info ""
        log.info "QC-ONLY MODE: Pipeline stopped"
        log.info "Results: ${params.outdir_multiqc}"
        return
    }

    // Alignment
    index_ch = Channel.value( file(params.indexforstar) )
    ALIGNMENT( QC.out.reads, index_ch )

    // Quantification
    gtf_ch = Channel.value( file(params.gtf_file) )
    QUANTIFICATION( ALIGNMENT.out.bam, gtf_ch )
}

workflow.onComplete {
    log.info ""
    log.info "Pipeline complete"
    log.info ""
    log.info "Output Directories:"
    log.info "   ├─ FastQC: ${params.outdir_fastqc}"
    if( params.trim ) {
        log.info "   ├─ Trimmed reads: ${params.outdir_trim}"
    }
    log.info "   ├─ Alignments (BAM): ${params.outdir_star}"
    log.info "   ├─ Gene counts: ${params.outdir_quant}"
    log.info "   └─ MultiQC report: ${params.outdir_multiqc}"
    log.info ""
}