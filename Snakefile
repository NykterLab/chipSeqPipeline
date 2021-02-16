# ------------------------------------------------------------------------------
# CHIP-Sequencing data processing pipeline
# Nykterlab, MIT License
# ------------------------------------------------------------------------------
# MODULES LOADING --------------------------------------------------------------
import time
import logging
# SET GLOBAL VARIABLES ---------------------------------------------------------
configFile = config["config"]
outputDir = config["outputDir"]
execDir = config["execDir"]
sampleSheet = config["sampleSheet"]
slurmLogs = config["slurmLogs"]
layout = config["layout"]
genome = config["genome"]
samples = config["samples"].keys()
# LOGS -------------------------------------------------------------------------
ts = time.localtime()
stamp = str(time.strftime('%Y-%m-%d-%H-%M-%S', ts))
# LOAD RULE MODULES ------------------------------------------------------------
include: "{}snake_modules/bwa.snakefile".format(execDir)
include: "{}snake_modules/mergeBam.snakefile".format(execDir)
# RULE ALL ---------------------------------------------------------------------
# TMP input:
def getMerged():
    samples = []
    reps = []
    for sample in config["samples"]:
        for rep in config["samples"][str(sample)]:
            samples.append(sample)
            reps.append(reps)
    return expand(outputDir + "alignments/replicatesBams/"
    "{sample}_{replicate}_sorted.bam",
    zip,
    sample = samples,
    replicate = reps)

rule all:
    message:
        "DONE; {}".format(stamp)
    input:
        getMerged()
