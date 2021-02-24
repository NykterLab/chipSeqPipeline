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
include: "{}snake_modules/filterMappedReads.snakefile".format(execDir)
include: "{}snake_modules/peakCalling.snakefile".format(execDir)
# WILDCARDS CONSTRAINS ---------------------------------------------------------
wildcard_constraints:
    replicate = "[^/]+",
    sample = "[^/]+",
    library = "[^/]+",
    lane = "[^/]+"
# TMP input: -------------------------------------------------------------------
def getMerged():
    samples = []
    reps = []
    for sample in config["samples"].keys():
        for rep in config["samples"][sample].keys():
            samples.append(sample)
            reps.append(rep)
    return expand(outputDir + "calls/sp_{sample}/"
    "rep_{replicate}/{replicate}_summits.bed",
    zip,
    sample = samples,
    replicate = reps)
# RULE ALL ---------------------------------------------------------------------
rule all:
    message:
        "DONE; {}".format(stamp)
    input:
        getMerged()
