# READ FILTERING ---------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
# RULES ------------------------------------------------------------------------
rule filterMappedReads:
    """Remove unmapped reads, secondary alignments and duplicates."""
    input:
        bam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam",
        bamIndex = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam.bai"
    output:
        filteredBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam",
        markdupMetrics = outputDir + "stats/sp_{sample}/"
        "{replicate}-filtered-markdup-metrics.txt"
    params:
        qualityThreshold = 1804 if layout == "paired" else 1796
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
        -F {params.qualityThreshold} \
        -q 30 \
        -b {input.bam} | \
        picard MarkDuplicates \
        INPUT=/dev/stdin \
        VALIDATION_STRINGENCY=LENIENT \
        ASSUME_SORTED=true \
        REMOVE_DUPLICATES=true \
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
