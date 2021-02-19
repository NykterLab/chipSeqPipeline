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
def getLanes():
    samples = []
    reps = []
    libs = []
    lanes = []
    for sample in config["samples"]:
        for rep in config["samples"][str(sample)]:
            for lib in config["samples"][str(sample)][str(rep)]:
                for lane in config["samples"][str(sample)][str(rep)][str(lib)]:
                    samples.append(sample)
                    reps.append(rep)
                    libs.append(lib)
                    lanes.append(lane)
    return expand(outputDir + "alignments/sorted_reads/sp_{sample}/"
    "rep_{replicate}/lib_{library}/lane_{lane}_sorted.bam", zip,
    sample = samples, replicate = reps, library = libs, lane = lanes)

def getMerged():
    samples = []
    reps = []
    for sample in config["samples"].keys():
        print(sample)
        for rep in config["samples"][sample].keys():
            print(rep)
            samples.append(sample)
            reps.append(rep)
    return expand(outputDir + "alignments/sp_{sample}/"
    "{replicate}-sorted.bai",
    zip,
    sample = samples,
    replicate = reps)

rule all:
    message:
        "DONE; {}".format(stamp)
    input:
        getMerged()
