# READ FILTERING ---------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
# RULES ------------------------------------------------------------------------
rule filterMappedReads:
    input:
        bam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam",
        bamIndex = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam.bai"
    output:
        filteredBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam"
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
        -F 1804 \
        -q 30 \
        -b {input.bam} | \
        picard MarkDuplicates \
        INPUT=/dev/stdin \
        VALIDATION_STRINGENCY=LENIENT \
        ASSUME_SORTED=true \
        REMOVE_DUPLICATES=true \
        OUTPUT={output.filteredBam}
        """
