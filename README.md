# RNA-seq Preprocessing Pipeline (Nextflow)

This repository contains a small modular Nextflow DSL2 pipeline for basic RNA-seq preprocessing and quantification.  
It performs:

1. Read quality control (FastQC)  
2. Adapter trimming (Trim Galore)  
3. Genome alignment (STAR)  
4. Gene-level quantification (featureCounts)  
5. QC summarization (MultiQC)

The pipeline processes paired-end FASTQ files defined via a sample sheet.

---

## Requirements

To run the pipeline you need:

- **STAR genome index**
- **GTF annotation file**
- **Sample Sheet**

The paths/files required to the STAR index and GTF file are provided via:

- `--indexforstar`
- `--gtf_file`
- `--samplesheet`

### Additional flags 

if you want to check adapters before moving on and decide wether to trim or not 
- `--onlyqc`
- `--trim`
  
---

## Sample Sheet Format

Input samples are defined in a CSV file with three required columns:

| sample_id | fastq_1 | fastq_2 |
|-----------|---------------------------|---------------------------|
| A  | path/to/A_R1.fastq.gz | /path/to/A_R2.fastq.gz |


---

## How to Run

### Run after indexing with STAR 

```bash
nextflow run main.nf \
  --samplesheet path/to/samplesheet.csv \
  --indexforstar path/to/star_index \
  --gtf_file path/to/annotation.gtf



