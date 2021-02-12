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
sampleSheet = config["sampleSheet"]
slurmLogs = config["slurmLogs"]
layout = config["layout"]
genome = config["genome"]
samples = config["samples"].keys()
# LOGS -------------------------------------------------------------------------
ts = time.localtime()
stamp = str(time.strftime('%Y-%m-%d-%H-%M-%S', ts))
# LOAD RULE MODULES ------------------------------------------------------------
include: "./snake_modules/split_per_sample.snakefile"
include: "./snake_modules/make_report.snakefile"
# RULE ALL ---------------------------------------------------------------------
rule all:
    message:
        "DONE; {}".format(stamp)
    input:
        outputDir + "GATK_germline_report.html"
