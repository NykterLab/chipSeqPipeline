# BAM MERGING RULES ------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
def getSampleBams(sample, replicate):
    libs = []
    lanes = []
    for lib in config["samples"][str(sample)][str(replicate)]:
        for lane in config["samples"][str(sample)][str(replicate)][lib]:
            libs.append(lib)
            lanes.append(lane)
    return expand(outputDir + \
                  "alignments/sorted_reads/sp_{{sample}}/"
                  "rep_{{replicate}}/lib_{library}/lane_{lane}_sorted.bam",
                  zip,
                  library = libs,
                  lane = lanes)

def formatBamsInput(sample, replicate, input):
    return " ".join([" -I " + b for b in input])
# RULES ------------------------------------------------------------------------
rule mergeBamPerReplicates:
    """Merge aligned read per replicates."""
    input:
        bams = lambda wildcards: \
        getSampleBams(wildcards.sample, wildcards.replicate)
    output:
        mergedBam = outputDir + "alignments/replicatesBams/"
        "{sample}_{replicate}_sorted.bam",
        mergedBamIndex = outputDir + "alignments/replicatesBams/"
        "{sample}_{replicate}_sorted.bai"
    params:
        bamsFormated = formatBamsInput
    benchmark:
        outputDir + "bench/mergeBamPerReplicates/"
        "sample_merge_{sample}_{replicate}.log"
    message:
        "Mergin BWA alignment for sample {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_mergeBamPerReplicates.log"
    shell:
        """
        picard MergeSamFiles \
        {params.bamsFormated} \
        -O {output.merged_bam} \
        --REFERENCE_SEQUENCE {genome} \
        --CREATE_INDEX
        """
