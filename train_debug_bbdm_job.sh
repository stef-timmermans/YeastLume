#!/bin/bash

#SBATCH --job-name=bbdm-debug-train
#SBATCH --partition=gpushort
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=logs/bbdm_debug_train_%j.out
#SBATCH --error=logs/bbdm_debug_train_%j.err

# Leave the script if an error is encountered
set -e

# Create log and temp directories
mkdir -p logs
export TMPDIR="$HOME/tmp"
mkdir -p "$TMPDIR"

# Load system modules for GPU support
module purge
module load CUDA/12.4.0

# Activate Conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate BBDM

# Navigate to BBDM code copied inside YeastLume
cd "$HOME/YeastLume/BBDM"

# Print debug info
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"
echo "Start time: $(date)"
nvidia-smi
echo "Python path: $(which python)"
echo "Working directory: $(pwd)"
echo ""

# If echo below succeeds, environment for BBDM has
# been successfully configured
echo "Debug check completed at: $(date)"
