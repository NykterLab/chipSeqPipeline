# PEAK CALLING -----------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
# TODO: add "mappable" genome size computation, used as input by macs2 -g.
# Depends on read size, coverage and filtering. Should be computed from
# filtered bams.
# RULES ------------------------------------------------------------------------
rule macs2PeakCalling:
    """Call peaks from aligned and filtered reads."""
    input:
        filteredBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam",
        filteredBamIndex = outputDir + "alignments/sp_{sample}/"
        "{replicate}-filtered.bam.bai"
    output:
        callDir = directory(outputDir + "calls/sp_{sample}/rep_{replicate}"),
        modelR = outputDir + "calls/sp_{sample}/"
        "rep_{replicate}/{replicate}_model.r",
        peaksXls = outputDir + "calls/sp_{sample}/"
        "rep_{replicate}/{replicate}_peaks.xls",
        peaksNarrow= outputDir + "calls/sp_{sample}/"
        "rep_{replicate}/{replicate}_peaks.narrowPeak",
        summits= outputDir + "calls/sp_{sample}/"
        "rep_{replicate}/{replicate}_summits.bed"
    benchmark:
        outputDir + "bench/macs2PeakCalling/"
        "macs2PeakCalling_{sample}_{replicate}.log"
    message:
        "Call peak for {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_macs2PeakCalling.log"
    singularity:
        "{}singularity/build/macs2".format(execDir)
    shell:
        """
        macs2 \
        callpeak \
        -f BAM \
        -t {input.filteredBam} \
        --outdir {output.callDir} \
        --name {wildcards.replicate}
        """
