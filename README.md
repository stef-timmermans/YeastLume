# 💡 YeastLume

YeastLume is a budding yeast microscopy tool that uses a diffusion-based generative model to reconstruct fluorescence images from bright-field input. It is trained on paired bright-field and fluorescence images stored in multi-channel .tif files. This repository includes preprocessing tools, training pipelines for the utilized models ([VQGAN](https://github.com/CompVis/taming-transformers/) and [BBDM](https://github.com/xuekt98/BBDM)), and utilities for running inference, evaluation, and segmentation (via [Cellpose](https://github.com/MouseLand/cellpose)).

![YeastLume Pipeline](media/yeastlume-pipeline.png)
*Starting from multi-channel .tif microscopy movies, the pipeline extracts frame pairs, translates bright-field frames into synthetic fluorescence using a trained BBDM, and segments the resulting images using Cellpose, returning binary cell masks.*

---

# ⚙️ Instructions
Below are steps for how to train a BBDM model with paired bright-field and fluorescence data. Steps 1 and 2 can be done via a local, Unix-based environment (e.g., macOS), but the remaining steps assume the use of a high-performance cluster (e.g., University of Groningen's Hábrók) for [Slurm](https://slurm.schedmd.com) jobs.

### Dataset
- The microscopy datasets used in this project are not publicly distributed, but the pipeline will work with .tif input files as long as the installation and preprocessing steps are followed and model configurations are adjusted.

### Local Requirements *(when applicable)*
- 512x512 multi-channel .tif films
- Python 3.11+ (with pip)
- Rclone *(if pushing/pulling data)*

### Remote Requirements
- Slurm job scheduling system
- Unix/Linux shell with CUDA GPU available
- Conda (via Anaconda3/2024.02-1)
- Rclone *(if pushing/pulling data)*

⚠️ **NOTE:** Slurm job scripts assume that the YeastLume project root is in the `$HOME` directory!

---

![Training Process](media/yeastlume-training.png)
*Raw .tif movies are manually split and then the two relevant channel frame subset pairs are saved for training, validation, and testing. The VQGAN learns a latent representation of the fluorescence images, and the BBDM is trained to generate these representations from bright-field inputs. Two distinct test sets are reserved for final inference on the BBDM.*


## 1. Setup Data Preparation
Run the data loading setup script for YeastLume's data preparation.

```shell
./scripts/preprocessing_setup.sh
```

---

## 2. Data Preparation and Preprocessing
BBDM expects data in a particular format for training, validating, and testing. To fulfill these requirements, allow the data preprocessing notebook to create paired image files.

These images have preprocessing applied to normalize their bright-field channels. In [`data`](./data), every tenth frame from the films is utilized. For each frame selected for the training set, five additional augmented copies with are created, namely:

- 90° rotation
- 180° rotation
- 270° rotation
- Horizontal flip
- Vertical flip

⚠️ **NOTE:** The preprocessing applies `gray` and `magma` colormaps to the bright-field and fluorescence frames, respectively, as the support for high-detail for VQGAN and BBDM is dubious. An improved version may include forks of the VQGAN and BBDM repository for full, guaranteed support of high-quality (uint32) images. Colormaps are thus currently utilized to support the models' learning of cell and nuclei placement.

The primary test set is generated along with the training and validation sets via the frame interval logic in [`data_preprocessing.ipynb`](./data-loading/data_preprocessing.ipynb).  A second  test set that utilizes every frame for evaluation is created via [`full_test_set_preprocessing.ipynb`](./data-loading/full_test_set_preprocessing.ipynb).

To generate the frame data, do the following:

1. Populate the [`data-loading/raw-data`](data-loading/raw-data) subdirectories with `512x512` multi-channel `.tif` files based on the desired split. These files should be in standard format with bright-field at channel zero and fluorescence at channel one. If data loading fails, please [see the related README](data-loading/README.md).

2. Run the preprocessing script to automatically create the respective data folders.
```shell
./scripts/preprocessing.sh
```

---

## 3. Remote Data Hosting via Rclone
Hosting the training data can be done via any service; however, this project was developed using Rclone—the University of Groningen's suggested data software module for Hábrók—with Google Cloud Platform. In order to correctly set up Google Drive as a storage space in a headless environment, ensure the following steps are taken:

1. Create a new Google Cloud Platform project.
2. Under "APIs and Services" → "Enabled APIs & services", click "+ Enable APIs and services" and search for and enable the Google Drive API.
3. Go to "APIs and Services" → "Credentials" and configure a basic consent screen. Configure for external use.
4. Under "Google Auth Platform" → "Data Access", add these scopes to the "Manually add scopes", and leave the resulting boxes ticked: `https://www.googleapis.com/auth/docs,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/drive.metadata.readonly`. Note to save changes in the bottom of the pop-up.
5. Under "Google Auth Platform" → "Audience", add yourself as a test user (**ensure the GCP project, your Google Drive, and test user are all the same account**).
6. Under "APIs and Services" → "Credentials", click "+ Create credentials" and select for an OAuth Client ID of type "Desktop app".
7. From the pop-up, download the provided JSON from the bottom-left button.
8. Move the created JSON file into [`accounts/`](./accounts) for convenience. It should automatically be ignored from tracking at this point.
9. Follow the [Hábrók documentation](https://wiki.hpc.rug.nl/habrok/data_management/google_drive) (or a substitute host with Rclone), specifically the section *"Loading and configuring the application"*. Copy the appropriate variable names from the Google Cloud Project JSON file and authenticate. Name the remote `gdrive`. This configuration should be done on each machine Rclone is used to push and pull data.
10. Push the model input data to remote (if training the model on a different machine than where preprocessing was done).
```shell
rclone copy -P data/ gdrive:YeastLume/data/
rclone copy -P full-test-data/ gdrive:YeastLume/full-test-data/
```

*Optional steps to facilitate group work with shared configurations are included at the bottom of this document under [Remote Data Hosting via Rclone (cont.)](#remote-data-hosting-via-rclone-cont)*.

---

## 4. Training the VQGAN
BBDM expects a VQGAN checkpoint as input to the model. [The repository links options in its "Pretrained Models" section](https://github.com/xuekt98/BBDM). You can follow their instructions to find an appropriate checkpoint (VQGAN-4, by default).

However, in order to maximize the efficacy of BBDM, it is recommended to train a new VQGAN to better learn how to reconstruct the fluorescence images from the training data. Note that the VQGAN model never sees the test set. To leverage a unique VQGAN, prepare for training with the following steps:

1. Pull the model input data from remote (if necessary).
```shell
module load rclone/1.66.0
rclone copy -P gdrive:YeastLume/data/ data/
```

2. Configure the Conda environment for the model (from [taming-transformers](https://github.com/CompVis/taming-transformers/)). This script was developed for the University of Groningen's Hábrók, so many install instructions may break on other machines. Please be sure to commit any hyperparameter changes to `custom_vqgan.yaml` beforehand.
```shell
./scripts/gan_setup.sh
```

3. Run the model training script via a dedicated job. This uses the `custom_vqgan.yaml` template.
```shell
sbatch scripts/jobs/train_vqgan_job.sh
```

*In the event of failure, a smaller test job can be run via `sbatch scripts/jobs/train_debug_vqgan_job.sh`. This script is the same as `train_vqgan_job.sh`, except it omits the actual Python call to build the model, and with much lighter GPU[-hour] usage.*

Train the VQGAN until results are as desired (the model will eventually plateau in performance).

⚠️ **NOTE:** An improvement to this repository is support for early stopping and saving the best VQGAN (checkpoints) based on metrics.

4. Push the model checkpoints to remote for safekeeping. This command assumes only one training log exists. To push to remote otherwise, populate the expanded subpath manually.
```shell
module load rclone/1.66.0
rclone copy -P $(ls -d taming-transformers/logs/*custom_vqgan)/checkpoints gdrive:YeastLume/VQGAN/checkpoints
```
---

## 5. Training the BBDM Model
With a checkpoint to a VQGAN, train the BBDM model with the following steps:

1. Pull the VQGAN checkpoint from remote (or move the file to [`checkpoints/VQGAN`](./checkpoints/VQGAN) manually). Please note that the BBDM model expects the VQGAN `last.ckpt` checkpoint file under [`checkpoints/VQGAN/`](checkpoints/VQGAN/). If this file is not present, the BBDM model will fail to begin training.
```shell
module load rclone/1.66.0
rclone copy -P gdrive:YeastLume/VQGAN/checkpoints/last.ckpt checkpoints/VQGAN/
```

2. Configure the Conda environment for the BBDM model. This script was developed for the University of Groningen's Hábrók, so many install instructions may break on other machines. Please be sure to commit any hyperparameter changes to `environment.yml` beforehand.
```shell
./scripts/bbdm_setup.sh
```

3. Run the model training script via a dedicated job. This uses the `Template-LBBDM-f4.yaml` template (latent space BBDM with a latent depth of 4).
```shell
sbatch scripts/jobs/train_bbdm_job.sh
```

*In the event of failure, a smaller test job can be run via `sbatch scripts/jobs/train_debug_bbdm_job.sh`. This script is the same as `train_bbdm_job.sh`, except it omits the actual Python call to build the model, and with much lighter GPU[-hour] usage.*

4. Push the model checkpoints to remote for safekeeping.
```shell
module load rclone/1.66.0
rclone copy -P BBDM/results/YeastLume/LBBDM-f4/checkpoint/ gdrive:YeastLume/BBDM/checkpoint
```

---

## 6. Running Inference on the BBDM Model

With the BBDM model trained, inference can be run on a selected checkpoint with the two different test sets for evaluation.

1. Pull both sets of remote data (if necessary).
```shell
module load rclone/1.66.0
rclone copy -P gdrive:YeastLume/data/ data/
rclone copy -P gdrive:YeastLume/full-test-data/ full-test-data/
```

2. Ensure that necessary (empty) folders exist for the expanded test set. This is necessary because BBDM checks for a valid data directory layout regardless of whether some folders are not read.
```shell
mkdir -p full-test-data/train/A
mkdir -p full-test-data/train/B
mkdir -p full-test-data/val/A
mkdir -p full-test-data/val/B
```

3. Pull the desired BBDM checkpoint from remote. For example, to clone the top-performing epoch , do: `rclone copy -P gdrive:YeastLume/BBDM/checkpoint/top_model_epoch_###.pth checkpoints/BBDM`, replacing the `###` with the actual number substring. The name of the checkpoint can be examined on Google Drive. Or move the checkpoint manually. If the VQGAN and BBDM checkpoints are not present, the BBDM model will either not begin evaluation or provide garbage output.

4. Run the evaluation script. This will write image test inference results in the preexisting BBDM-related subdirectory, as well as a new one named "YeastLume-Full-Test-Set".
```shell
sbatch scripts/jobs/eval_bbdm_job.sh
```

5. Run metrics on the supplied images. PSNR and SSIM measure reconstruction fidelity and structural similarity between predicted and ground-truth fluorescence images, while MSE captures pixel-wise error.
```shell
./scripts/metrics_setup.sh
./scripts/metrics.sh
```

---

## 7. Binary Cell Mask Generation

From the evaluation output fluorescence frames, utilize [Cellpose](https://github.com/MouseLand/cellpose) to create 512x512 binary masks to aid downstream segmentation.

1. Configure the Conda environment for the Cellpose model. This script was developed for the University of Groningen's Hábrók, so many install instructions may break on other machines.
```shell
./scripts/cellpose_setup.sh
```

2. Segment via Cellpose on the evaluation images (single-channel segmentation). Images will be stored in [`segmentation/masks/`](./segmentation/masks).

```shell
sbatch scripts/jobs/cellpose_isolated_job.sh
```

*In the event of failure, a smaller test job can be run via `sbatch scripts/jobs/cellpose_debug_isolated_job.sh`. This script is the same as `cellpose_isolated_job.sh`, except it omits the actual Python call to run the model, and with much lighter GPU[-hour] usage.*

---

# 🖥 Supplementary Install Information

---

## Remote Data Hosting via Rclone (cont.)

Note via [the Remote Data Hosting via Rclone section](#3-remote-data-hosting-via-rclone) that these steps are optional and are only needed if sharing a single Google Drive data setup.

1. Rename the JSON file in [`accounts/`](./accounts) to `drive.json` to remove it from tracking. 
2. Install [SOPS](https://getsops.io/docs/#download) and run the encryption script, which should create `key` in [`accounts/`](./accounts). This file is more obscure, and can more safely be passed in messages, as it does not directly link to any user space. Changes to the encrypted JSON file are tracked by Git.
```shell
./accounts/encrypt.sh
```
3. When running in a different copy of the repository, bring a copy of the correct `key` back into [`accounts/`](./accounts) manually, and run the decryption script.
```shell
./accounts/decrypt.sh
```

---

## Prevent Committing Output from Notebooks

Add this line to your shell configuration:
```shell
git config filter.strip-notebook-output.clean 'jupyter nbconvert --ClearOutputPreprocessor.enabled=True --to=notebook --stdin --stdout --log-level=ERROR'
```

**[Source](https://gist.github.com/33eyes/431e3d432f73371509d176d0dfb95b6e)**
