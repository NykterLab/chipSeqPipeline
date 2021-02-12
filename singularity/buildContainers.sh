#! /usr/bin/bash
# BUILD PIPELINE CONTAINERS ----------------------------------------------------
mkdir -p build/ logs/ test/
sudo singularity build build/base recipes/base.rcp > logs/base.log
