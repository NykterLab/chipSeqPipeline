# BAM MERGING ------------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
def getRepStructure(wildcards):
    return config["samples"][wildcards.sample][wildcards.replicate]

def getReplicateBams(wildcards):
    replicateStruct = getRepStructure(wildcards)
    libs = []
    lanes = []
    for lib in replicateStruct.keys():
        for lane in replicateStruct[lib]:
            libs.append(lib)
            lanes.append(lane)
    return expand(outputDir + \
                  "alignments/sorted_reads/sp_{{sample}}/"
                  "rep_{{replicate}}/lib_{library}/lane_{lane}_sorted.bam",
                  zip,
                  library = libs,
                  lane = lanes)

def formatBamsInput(wildcards, input):
    return " ".join([" I=" + b for b in input])
# RULES ------------------------------------------------------------------------
rule mergeBamPerReplicates:
    """Merge aligned read per replicates."""
    input:
        bams = getReplicateBams
    output:
        mergedBam = temp(outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam")
    params:
        bamsFormated = formatBamsInput
    benchmark:
        outputDir + "bench/mergeBamPerReplicates/"
        "mergeBamPerReplicates_{sample}_{replicate}.log"
    message:
        "Mergin BWA alignment for sample {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_mergeBamPerReplicates.log"
    singularity:
        "{}singularity/build/picard".format(execDir)
    shell:
        """
        picard MergeSamFiles \
        {params.bamsFormated} \
        O={output.mergedBam} \
        MERGE_SEQUENCE_DICTIONARIES=true
        """

rule indexBam:
    "Index merged bam."
    input:
        mergedBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam"
    output:
        mergedBamIndex = temp(outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam.bai")
    benchmark:
        outputDir + "bench/indexBam/"
        "indexBam_{sample}_{replicate}.log"
    message:
        "Indexing bam file for {wildcards.sample}, "
        "replicate: {wildcards.replicate}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{sample}_{replicate}_indexBam.log"
    singularity:
        "{}singularity/build/base".format(execDir)
    shell:
        """
        samtools \
        index \
        -@ 4 \
        {input.mergedBam}
        """
