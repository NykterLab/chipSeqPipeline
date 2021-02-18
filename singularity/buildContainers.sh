#! /usr/bin/bash
# BUILD PIPELINE CONTAINERS ----------------------------------------------------
mkdir -p build/ logs/ test/
sudo singularity build build/base recipes/base.rcp > logs/base.log
sudo singularity build build/bwa recipes/bwa.rcp > logs/bwa.log
sudo singularity build build/picard recipes/picard.rcp > logs/picard.log
