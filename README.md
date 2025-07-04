# YeastLume
Repository for the YeastLume data pipeline. Follow the directions below to configure the repository for your own purposes.

# Installation and Use
Below are instructions on how to train a BBDM model with paired bright-field and fluorescence data.

### Local Requirements
- 512x512 multi-channel .tif films
- Python 3.11+
- Rclone *(if pushing/pulling data)*

### Remote Requirements
- SLURM job scheduler
- Unix/Linux shell with CUDA GPU available
- Conda (using Python 3.9.16)
- Rclone *(if pushing/pulling data)*

---

## 1. Setup Data Preparation
Run the data loading setup script for YeastLume's data preparation.

```shell
./scripts/preprocessing_setup.sh
```

---

## 2. Data Preparation and Preprocessing
BBDM expects data in a particular format for training, validating, and testing. To fulfill these requirements, allow the data preprocessing notebook to create individual, paired image files.

1. Populate the [`data-loading/raw-data`](data-loading/raw-data) directory with your multi-channel `.tif` files of `512x512` films. These files should be in standard format with bright-field at channel zero and fluorescence at channel one. If data loading fails, please [see the related README](data-loading/README.md).
2. Run the preprocessing script.
```shell
./scripts/preprocessing.sh
```

*Note this script does not save notebook output other than the created data directory. In the event of errors, see Line 9 of [`preprocessing.sh`](scripts/preprocessing.sh).*

---

## 3. Remote Data Hosting via Rclone
Hosting the training data can be done via any service; however, this project was developed using Rclone—University of Groningen's suggested data software module for Hábrók—with Google Cloud Platform. In order to correctly setup Google Drive as a storage space in a headless environment, ensure the following steps are taken on a **new fork (or copy)* of the repository:

1. Create a new Google Cloud Platform project.
2. Under "APIs and Services" → "Enabled APIs & services", click "+ Enable APIs and services" and search for and enable the Google Drive API.
3. Go to "APIs and Services" → "Credentials" and configure a basic consent screen. Configure for external use.
4. Under "Google Auth Platform" → "Data Access", add these scopes to the "Manually add scopes", and leave the resulting boxes ticked: `https://www.googleapis.com/auth/docs,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/drive.metadata.readonly`. Note to save changes in the bottom of the pop-up.
5. Under "Google Auth Platform" → "Audience", add yourself as a test user (**ensure the GCP project, your Google Drive, and test user are all the same account**).
6. Under "APIs and Services" → "Credentials", click "+ Create credentials" and select for an OAuth Client ID of type "Desktop app".
7. From the pop-up, download the provided JSON from the bottom-left button.
8. Move the created JSON file into [`/accounts`](./accounts) for convenience. It should automatically be ignored from tracking at this point.
9. Follow the [University of Groningen Hábrók documentation](https://wiki.hpc.rug.nl/habrok/data_management/google_drive) (or a substitute host supporting Rclone), specifically the section *"Loading and configuring the application"*. Copy the appropriate variable names from the Google Cloud Project JSON file and authenticate. Name the remote `gdrive`. This configuration should be done on each machine Rclone is used to push and pull data.
10. Push the model input data to remote (if training the model on a different machine).
```shell
rclone copy -P data/ gdrive:YeastLume/data/
```

*Optional steps if involving multiple researchers/developers are included at the bottom of this document under [Remote Data Hosting via Rclone (cont.)](#remote-data-hosting-via-rclone-cont)*.

---

## 4. Training the VQGAN
BBDM expects a VQGAN checkpoint as input to the model. [The repository links options in its "Pretrained Models" section](https://github.com/xuekt98/BBDM). You can follow their instructions to find an appropriate checkpoint (VQGAN-4, by default).

However, in order to maximize the efficacy of BBDM, it is also possible to train a new VQGAN to learn to reconstruct the fluorescence images in `data/train/B`. The model does not have access to the test set. Prepare the model with the following steps:

1. Pull the model input data from remote (if necessary).
```shell
module load rclone/1.66.0
rclone copy -P gdrive:YeastLume/data/ data/
```

2. Configure the Conda environment for the model ([taming-transformers](https://github.com/CompVis/taming-transformers/)). This script was developed for the University of Groningen's Hábrók, so many install instructions may break on other machines.
```shell
./scripts/gan_setup.sh
```

3. Run the model training script via a dedicated job. This uses the `custom_vqgan.yaml` template.
```shell
sbatch scripts/jobs/train_vqgan_job.sh
```

*In the event of failure, a smaller test job can be run via `sbatch scripts/jobs/train_debug_vqgan_job.sh`. This script is the same as `train_vqgan_job.sh`, only missing the actual Python call to build the model, and with much lighter GPU[-hour] usage.*

Train the VQGAN until results are as desired (the model will plateau in performance). Then the checkpoint to remote for safekeeping and the related training and validation images, if desired. These commands assume only one log exists. To push to remote otherwise, populate the expanded subpath manually.
```shell
module load rclone/1.66.0
rclone copy -P $(ls -d taming-transformers/logs/*custom_vqgan)/checkpoints gdrive:YeastLume/VQGAN/checkpoints
rclone copy -P $(ls -d taming-transformers/logs/*custom_vqgan)/images gdrive:YeastLume/VQGAN/images
```

## 5. Training the BBDM Model
With a checkpoint to a VQGAN, train the BBDM model with the following steps:

1. Pull the model input data from remote (if necessary), as well as the VQGAN checkpoint (if not using pretrained).
```shell
module load rclone/1.66.0
rclone copy -P gdrive:YeastLume/data/ data/
rclone copy gdrive:YeastLume/VQGAN/checkpoints/last.ckpt checkpoints/VQGAN/
```

2. Configure the Conda environment for the model ([BBDM](https://github.com/xuekt98/BBDM)). This script was developed for the University of Groningen's Hábrók, so many install instructions may break on other machines.
```shell
./scripts/bbdm_setup.sh
```

3. Run the model training script via a dedicated job. This uses the `Template-LBBDM-f4.yaml` template (latent space BBDM with a latent depth 4).
```shell
sbatch scripts/jobs/train_bbdm_job.sh
```

*In the event of failure, a smaller test job can be run via `sbatch scripts/jobs/train_debug_bbdm_job.sh`. This script is the same as `train_bbdm_job.sh`, only missing the actual Python call to build the model, and with much lighter GPU[-hour] usage.*


4. Push the model training output to remote for safekeeping (you can use a more specific filepath if you wish to exclude unnecessary data).
```shell
module load rclone/1.66.0
rclone copy -P BBDM/results/ gdrive:YeastLume/BBDM/results
```

---

## Remote Data Hosting via Rclone (cont.)

Note via [the Remote Data Hosting via Rclone section](#3-remote-data-hosting-via-rclone) that these steps are optional and are only needed if sharing a single Google Drive data setup.

1. Rename the JSON file in [`/accounts`](./accounts) to `drive.json`. 
2. Install [SOPS](https://getsops.io/docs/#download) and run the encryption script, which should create `key` in [`/accounts`](./accounts). This file is more obscure, and can more safely be passed in messages, as it does not directly link to any user space. Changes to the encrypted JSON file are tracked by Git.
```shell
./accounts/encrypt.sh
```
3. When running in a different copy of the repository, bring a copy of the correct `key` back into [`/accounts`](./accounts) manually, and run the decryption script.
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
