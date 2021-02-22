# READ FILTERING ---------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
# RULES ------------------------------------------------------------------------
rule filterMappedReads:
    """
    Remove unmapped reads, secondary alignments,
    low quality mapping, (Samtools) and duplicates (Picard MarkDuplicates).
    """
    input:
        bam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam"
    output:
        filteredBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam",
        markdupMetrics = outputDir + "stats/sp_{sample}/"
        "{replicate}-filtered-markdup-metrics.txt"
    params:
        samFlag = 2828
    benchmark:
        outputDir + "bench/indexBam/"
        "filterMappedReads_{sample}_{replicate}.log"
    message:
        "Filtering bam file for {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_filterMappedReads.log"
    singularity:
        "{}singularity/build/picard".format(execDir)
    shell:
        """
        samtools \
        view \
        -@ 2 \
        -F {params.samFlag} \
        -q 20 \
        -b {input.bam} | \
        samtools \
        sort \
        -@ 2 \
        - | \
        picard MarkDuplicates \
        INPUT=/dev/stdin \
        VALIDATION_STRINGENCY=LENIENT \
        ASSUME_SORTED=true \
        REMOVE_DUPLICATES=false \
        METRICS_FILE={output.markdupMetrics} \
        OUTPUT={output.filteredBam}
        """

rule indexFilteredBam:
    "Index filtered bam."
    input:
        filteredBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam"
    output:
        filteredBamIndex = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam.bai"
    benchmark:
        outputDir + "bench/indexBam/"
        "indexFilteredBam_{sample}_{replicate}.log"
    message:
        "Indexing filtered bam file for {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_indexFilteredBam.log"
    singularity:
        "{}singularity/build/base".format(execDir)
    shell:
        """
        samtools \
        index \
        -@ 4 \
        {input.filteredBam}
        """
