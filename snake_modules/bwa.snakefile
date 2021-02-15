# ALIGNMENT RULES --------------------------------------------------------------
# WILDCARDS CONSTRAINS ---------------------------------------------------------
wildcard_constraints:
    replicate = "[^/]+",
    sample = "[^/]+",
    library = "[^/]+",
    lane = "[^/]+"
# FUNCTIONS --------------------------------------------------------------------
def getR1(wildcards):
    return config["samples"][wildcards.replicate][wildcards.sample]\
[wildcards.library][wildcards.lane]["R1"]

def getR2(wildcards):
    return config["samples"][wildcards.replicate][wildcards.sample]\
[wildcards.library][wildcards.lane]["R2"]

def getReadTag(wildcards):
    return config["samples"][wildcards.replicate][wildcards.sample]\
[wildcards.library][wildcards.lane]["rgTag"]
# RULES ------------------------------------------------------------------------
rule bwaPerLane:
    """Align reads to reference genome using BWA."""
    input:
        ref = genome,
        R1 = getR1,
        if layout == "paired":
            R2 = getR2
    params:
        tmp_dir = outputDir + "alignments/sorted_reads/"
        "sp_{sample}/rep_{replicate}/lib_{library}/lane_{lane}",
        rgTag = getReadTag
    output:
        temp(outputDir + "alignments/sorted_reads/sp_{sample}/"
        "rep_{replicate}/lib_{library}/lane_{lane}_sorted.bam")
    benchmark:
        outputDir + "bench/bwaPerLane/{replicate}-{sample}-{library}-{lane}.log"
    message:
        "Running BWA alignment for sample: "
        "{wildcards.sample}, replicate {wildcards.replicate}, "
        "library: {wildcards.library}, lane: {wildcards.lane}."
    log:
        outputDir + "snakemake_logs/" \
        + stamp + "{replicate}-{sample}-{library}-{lane}_bwaPerLane.log"
    run:
        if layout == "single":
            shell("""
                  mkdir -p {params.tmp_dir}
                  bwa mem \
                  -t 8 \
                  -R '{params.rgTag}' \
                  {input.ref} \
                  {input.R1} \
                  | samtools view -@ 8 -bS - \
                  | samtools sort -T {params.tmp_dir} -@ 8 - > {output}
                  rmdir {params.tmp_dir}
                  """)
        elif layout == "paired":
            shell("""
                  mkdir -p {params.tmp_dir}
                  bwa mem \
                  -t 8 \
                  -R '{params.rgTag}' \
                  {input.ref} \
                  {input.R1} \
                  {input.R2} \
                  | samtools view -@ 8 -bS - \
                  | samtools sort -T {params.tmp_dir} -@ 8 - > {output}
                  rmdir {params.tmp_dir}
                  """)
