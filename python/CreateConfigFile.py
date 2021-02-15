################################################################################
#               CHIP-seq pipeline configuration file creator                   #
################################################################################
# MODULES ----------------------------------------------------------------------
import argparse, os, csv, yaml, sys
# GLOBALS ----------------------------------------------------------------------
layouts = ['single', 'paired']
singleEndSampleSheetHeaders = ['SAMPLE','REPLICATE','LIBRARY','LANE','R1']
pairedEndSampleSheetHeaders = singleEndSampleSheetHeaders + ['R2']
# ARGUMENTS --------------------------------------------------------------------
parser = argparse.ArgumentParser(description='CHIP-seq pipeline configuration '
                                 'file creator.')
parser.add_argument('--sampleSheet', dest='sampleSheet', action='store',
help='Absolute path to sample sheet.')
parser.add_argument('--layout', dest='layout', action='store',
help='Sequencing layout, single or paired.')
parser.add_argument('--genome', dest='genome', action='store',
help='Absolute path to reference genome; must be indexed with bwa.')
parser.add_argument('--outputDir', dest='outputDir', action='store',
help='Absolute path to the output directory, will be created MUST NOT EXIST.')
parser.add_argument('--controlTracks', dest='controlTracks', action='store',
help='Absolute path to control tracks / TODO.')
parser.add_argument('--execDir', dest='execDir', action='store',
help='Path to pipeline git repository.')
args = parser.parse_args()
# CHECK ARGUMENTS --------------------------------------------------------------
# OUTPUT DIRECTORY ---
if os.path.isdir(args.outputDir):
    raise Exception("STOP! Directory {} already exist, the script stoped "
    "to prevent overwrite.".format(args.outputDir))
# SAMPLE SHEET ---
if not os.path.isfile(args.sampleSheet):
    raise Exception("Cannot find sample sheet at {}".format(args.sampleSheet))
# CONTROL TRACKS ---
# # TODO: add control tracks support
# LAYOUT ---
if args.layout not in layouts:
    raise Exception("Invalid layout, choose from: {}".format(layouts))
# GENOME ---
if not os.path.isfile(args.genome):
    raise Exception("Genome file ({}) not found.".format(args.genome))
# EXECDIR ---
if not os.path.isdir(args.execDir):
    raise Exception("Code folder {} not found.".format(args.execDir))
if not args.execDir.endswith("/"):
    args.execDir = args.execDir + "/"
# PARSE SAMPLE FILE ------------------------------------------------------------
sampleFileAsDict = csv.DictReader(open(args.sampleSheet), delimiter="\t")
print(i for i in sampleFileAsDict)
# CREATE OUPUT DIRECTORY -------------------------------------------------------
if not args.outputDir.endswith("/"):
    args.outputDir = args.outputDir + "/"
try:
    os.makedirs(args.outputDir)
except:
    raise Exception("Cannot create output directory "
                    "at: {}".format(args.outputDir))
os.makedirs(args.outputDir + "slurm_logs/")
# WRITE CONFIGURATION FILE -----------------------------------------------------
sampleFileFormat = \
singleEndSampleSheetHeaders if args.layout == 'single' \
else pairedEndSampleSheetHeaders
sampleFileReader = csv.DictReader(open(args.sampleSheet), delimiter=',')
dictStore = {}
for line in sampleFileReader:
    for field in sampleFileFormat:
        if field not in line:
            raise Exception("Sample file as invalid format.")
        if line["SAMPLE"] not in dictStore:
            dictStore[line["SAMPLE"]] = {}
        if line["REPLICATE"] not in dictStore[line["SAMPLE"]]:
            dictStore[line["SAMPLE"]][line["REPLICATE"]] = {}
        if line["LIBRARY"] not in dictStore[line["SAMPLE"]][line["REPLICATE"]]:
            dictStore[line["SAMPLE"]][line["REPLICATE"]][line["LIBRARY"]] = {}
        dictStore[line["SAMPLE"]][line["REPLICATE"]][line["LIBRARY"]]\
        [line["LANE"]] = {}
        dictStore[line["SAMPLE"]][line["REPLICATE"]][line["LIBRARY"]]\
        [line["LANE"]]["R1"] = line["R1"]
        if args.layout == "paired":
            dictStore[line["SAMPLE"]][line["REPLICATE"]][line["LIBRARY"]]\
            [line["LANE"]]["R2"] = line["R2"]
        readTag = "\'@RG\\tID:{0}\\tLB:{1}\\tPL:{2}\\tSM:{3}\'".\
        format(line["SAMPLE"] + "_" + line["REPLICATE"],
               line["LIBRARY"], "ILLUMINA", line["LANE"])
        dictStore[line["SAMPLE"]][line["REPLICATE"]][line["LIBRARY"]]\
        [line["LANE"]]["rgTag"] = readTag
dictStorePrint = {}
dictStorePrint["samples"] = dictStore
# PRINT COHORT STRUCTURE -------------------------------------------------------
with open(args.outputDir + "config.yaml", "w") as outFile:
    outFile.write("# --- CHIP-seq pipeline configuration file ---\n")
    outFile.write("config: {}config.yaml\n".format(args.outputDir))
    outFile.write("outputDir: {}\n".format(args.outputDir))
    outFile.write("execDir: {}\n".format(args.execDir))
    outFile.write("sampleSheet: {}\n".format(args.sampleSheet))
    outFile.write("slurmLogs: {}\n".format(args.outputDir + "slurm_logs/"))
    outFile.write("layout: {}\n".format(args.layout))
    outFile.write("genome: {}\n".format(args.genome))
    outFile.write(yaml.dump(dictStorePrint))
