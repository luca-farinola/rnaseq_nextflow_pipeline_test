for r1 in data_small/fastq/*R1*.fastq; do
    r2=${r1/R1/R2}
    sample=$(basename $r1 _R1.small.fastq)
    echo "$sample,$r1,$r2"
done
