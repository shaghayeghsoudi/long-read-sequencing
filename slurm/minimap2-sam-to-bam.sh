#!/bin/bash -l
# ---------------------------------------------------------------------
# SLURM script for minimap2
# ---------------------------------------------------------------------
#SBATCH --job-name==minimap2
#SBATCH --cpus-per-task=1
#SBATCH --array=1-2
#SBATCH --mem-per-cpu=50G
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --time=30:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=shsoudi
#SBATCH --partition=emoding
#SBATCH --export=ALL
#module purge
# Activate Anaconda work environment for OpenDrift

#source /home/users/shsoudi/.bashrc
#conda init bash
source ~/anaconda3/etc/profile.d/conda.sh
source activate /home/users/shsoudi/emoding/envs/longqc


## Directories:
FASTA_DIR=/oak/stanford/groups/emoding/sequencing/pipeline/indices

ROOT_DIR=/oak/stanford/groups/emoding/analysis/shaghayegh/longreads-SV/pacbio2
CONFIG=${ROOT_DIR}/config.txt

SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)


FASQ_DIR_RAW=/oak/stanford/groups/emoding/sequencing/fastq/Pacbio2/p1/usftp21.novogene.com/HiFi_data/fastqs_from_bams

# Output directory
OUTPUT_DIR_RAW=${ROOT_DIR}/minimap2/${SAMPLE}
mkdir -p ${OUTPUT_DIR_RAW}


## Input file
FASTQ_RAW=${FASQ_DIR_RAW}/${SAMPLE}.fastq.gz


minimap2 -ax map-hifi ${FASTA_DIR}/hg19.fa ${FASTQ_RAW} -t 5 | samtools view -bS | samtools sort -o ${OUTPUT_DIR_RAW}/${SAMPLE}_q0l0_HiFi.bam
#samtools index ${OUTPUT_DIR_RAW}/${SAMPLE}_q0l0_HiFi.bam



