#!/bin/bash -l
# ---------------------------------------------------------------------
# SLURM script for fastqc
# ---------------------------------------------------------------------
#SBATCH --job-name==fastqc
#SBATCH --cpus-per-task=1
#SBATCH --array=1-2
#SBATCH --mem-per-cpu=40G
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --time=48:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=shsoudi
#SBATCH --partition=emoding
#SBATCH --export=ALL
#module purge
# Activate Anaconda work environment for OpenDrift


# ---------------------------------------------------------------------
echo "Current working directory: `pwd`"
echo "Starting run at: `date`"
# ---------------------------------------------------------------------
echo ""
echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"
echo "This is job $SLURM_ARRAY_TASK_ID out of $SLURM_ARRAY_TASK_COUNT jobs."
echo ""

## Locate the fastqc
source ~/anaconda3/etc/profile.d/conda.sh
source activate /home/users/shsoudi/emoding/envs/samtools112


## Directories:
# Locate the input data
ROOT_DIR=/oak/stanford/groups/emoding/sequencing/fastq/Pacbio2/p1/usftp21.novogene.com/HiFi_data

# Specify the path to the config file
CONFIG=${ROOT_DIR}/config.txt

# Extract the sample name for the current $SLURM_ARRAY_TASK_ID
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)
SAMPLE_DIR=${ROOT_DIR}/${SAMPLE}

BASE_NAME=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIG)

SAMPLE_BAM=${SAMPLE_DIR}/${BASE_NAME}.hifi_reads.bam


OUTPUT_DIR=/oak/stanford/groups/emoding/sequencing/fastq/Pacbio2/p1/usftp21.novogene.com/HiFi_data/fastqs_from_bams
mkdir -p ${OUTPUT_DIR}



bedtools bamtofastq -i ${SAMPLE_BAM} -fq ${OUTPUT_DIR}/${SAMPLE}.fastq

# ---------------------------------------------------------------------
echo "Job finished with exit code $? at: `date`"
# ---------------------------------------------------------------------
 

