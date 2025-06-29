#!/bin/bash

#SBATCH --job-name=bbdm-yeast-train
#SBATCH --partition=gpulong
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:v100:1
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=logs/bbdm_yeast_train_%j.out
#SBATCH --error=logs/bbdm_yeast_train_%j.err

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

# Print info for logging
echo "Job ID: $SLURM_JOB_ID"
echo "Running on: $(hostname)"
echo "Start time: $(date)"
nvidia-smi
echo "Python path: $(which python)"
echo "Working directory: $(pwd)"
echo ""

# Launch training
python3 main.py \
  --config configs/Template-BBDM.yaml \
  --train \
  --sample_at_start \
  --save_top \
  --gpu_ids 0

echo "Training finished at: $(date)"
