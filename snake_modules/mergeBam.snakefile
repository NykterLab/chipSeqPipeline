# BAM MERGING ------------------------------------------------------------------
# FUNCTIONS --------------------------------------------------------------------
def getRepStructure(wildcards):
    print(wildcards.replicate)
    return config["samples"][wildcards.sample][wildcards.replicate]

def getReplicateBams(wildcards):
    replicateStruct = getRepStructure(wildcards)
    libs = []
    lanes = []
    for lib in replicateStruct.keys():
        print(lib)
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
        mergedBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam",
        #mergedBamIndex = outputDir + "alignments/sp_{sample}/"
        #"{replicate}-sorted.bai"
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
    input:
        mergedBam = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam"
    output:
        mergedBamIndex = outputDir + "alignments/sp_{sample}/"
        "{replicate}-sorted.bam.bai"
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
