#!/bin/bash

#SBATCH --job-name=vqgan-debug-train
#SBATCH --gpus-per-node=v100:1
#SBATCH --partition=gpushort
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:15:00
#SBATCH --output=logs/vqgan_debug_train_%j.out
#SBATCH --error=logs/vqgan_debug_train_%j.err

# Leave the script if an error is encountered
set -e

# Create log and temp directories
mkdir -p logs
export TMPDIR="$HOME/tmp"
mkdir -p "$TMPDIR"

# Load system modules for GPU support
module purge
module load CUDA/12.4.0

# Load Conda
module load Anaconda3/2024.02-1
eval "$(conda shell.bash hook)"

# Activate Conda environment
conda activate taming

# Navigate to taming-transformers code copied inside YeastLume
cd "$HOME/YeastLume/taming-transformers"

# Print environment info for logging
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"
echo "Start time: $(date)"
nvidia-smi
echo "Python path: $(which python)"
echo "Working directory: $(pwd)"
echo "Conda version: $(conda --version)"
echo "Python version: $(python --version)"
echo ""

# If echo below succeeds, environment for taming-transformers
# has been successfully configured
echo "Training finished at: $(date)"
