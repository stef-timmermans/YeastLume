#!/bin/bash

#SBATCH --job-name=bbdm-yeast-train
#SBATCH --gpus-per-node=a100:1
#SBATCH --partition=gpushort
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=logs/bbdm_yeast_eval_%j.out
#SBATCH --error=logs/bbdm_yeast_eval_%j.err

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
conda activate BBDM

# Navigate to BBDM code copied inside YeastLume
cd "$HOME/YeastLume/BBDM"

# Find the BBDM top model checkpoint
TOP_MODEL_PATH=$(find "$HOME/YeastLume/checkpoints/BBDM" -type f -name "top_model_epoch_*.pth" | head -n 1)

# Fail if no file found
if [[ -z "$TOP_MODEL_PATH" ]]; then
  echo "No top model checkpoint found! Exiting..."
  exit 1
fi

echo "Using top model checkpoint: $TOP_MODEL_PATH"

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

# Launch intra .tif file evaluation
python3 main.py \
  --config configs/Template-LBBDM-f4.yaml \
  --sample_to_eval \
  --gpu_ids 0 \
  --resume_model "$TOP_MODEL_PATH"

echo "Evaluation on same-file frames finished at: $(date)"
echo ""

echo "Sleeping for 10 seconds to prevent model errors..."
echo ""
sleep 10

# Launch inter .tif file evaluation
python3 main.py \
  --config configs/Template-LBBDM-f4-unseen.yaml \
  --sample_to_eval \
  --gpu_ids 0 \
  --resume_model "$TOP_MODEL_PATH"

echo "Evaluation on unseen-file frames finished at: $(date)"
