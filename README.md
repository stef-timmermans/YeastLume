# YeastLume
Repository for the YeastLume data pipeline. Follow the directions below to configure the repository for your own purposes.

---

## 1. Initial Setup
Run the setup script for the repository. The script will exit on failure and assumes that Python, Pip, Conda, and Git are installed. It sets up a virtual environment, installs Python dependencies, and clones the utilized model ([BBDM](https://github.com/xuekt98/BBDM)).
```shell
./initial_setup.sh
```

---

## 2. Remote Data Hosting via Rclone
Hosting the training data can be done via any service; however, this project was developed using Rclone—University of Groningen's suggested data software module for Hábrók—with Google Cloud Platform. In order to correctly setup Google Drive as a storage space in a headless environment, ensure the following steps are taken on a **new fork** of the repository:

1. Create a new Google Cloud Platform project.
2. Under "APIs and Services" → "Enabled APIs & services", click "+ Enable APIs and services" and search for and enable the Google Drive API.
3. Go to "APIs and Services" → "Credentials" and configure a basic consent screen. Configure for external use.
4. Under "Google Auth Platform" → "Data Access", add these scopes to the "Manually add scopes", and leave the resulting boxes ticked: `https://www.googleapis.com/auth/docs,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/drive.metadata.readonly`. Note to save changes in the bottom of the pop-up.
5. Under "Google Auth Platform" → "Audience", add yourself as a test user (**ensure the GCP project, your Google Drive, and test user are all the same account**).
6. Under "APIs and Services" → "Credentials", click "+ Create credentials" and select for an OAuth Client ID of type "Desktop app".
7. From the pop-up, download the provided JSON from the bottom-left button.
8. Move the created JSON file into [`/accounts`](./accounts) for convenience. It should automatically be ignored from tracking at this point.
9. Follow the [University of Groningen Hábrók documentation](https://wiki.hpc.rug.nl/habrok/data_management/google_drive) (or a substitute host supporting Rclone), specifically the section *"Loading and configuring the application"*. Copy the appropriate variable names from the Google Cloud Project JSON file and authenticate.

*Optional steps if involving multiple researchers/developers are included at the bottom of this document under [Remote Data Hosting via Rclone (cont.)](#remote-data-hosting-via-rclone-cont)*.

---

## 3. Data Preparation and Preprocessing
BBDM expects data in a particular format to train, validate, and test the model. To fulfill these requirements, allow the data preprocessing notebook to create individual, paired image files.

1. Populate the [`data-loading/raw-data`](data-loading/raw-data) directory with your `.tif` files. These files should be in standard format with bright-field at channel zero and fluorescence at channel one. If data loading fails, please [see the related README](data-loading/README.md).
2. Run the preprocessing script.
```shell
./preprocessing.sh
```

*Note this script does not save notebook output other than the created data directory. In the event of errors, remove see Line 9 of [`preprocessing.sh`](preprocessing.sh).*

---

## Remote Data Hosting via Rclone (cont.)

Note via [the Remote Data Hosting via Rclone section](#2-remote-data-hosting-via-rclone) that these steps are optional and are only needed if sharing a single Google Drive data setup.

10. Rename the JSON file in [`/accounts`](./accounts) to `drive.json`. 
11. Install [SOPS](https://getsops.io/docs/#download) and run the encryption script, which should create `key` in [`/accounts`](./accounts). This file is more obscure, and can more safely be passed in messages, as it does not directly link to any user space. Changes to the encrypted JSON file are tracked by Git.
```shell
./accounts/encrypt.sh
```
12. When running in a different copy of the repository, bring a copy of the correct `key` back into [`/accounts`](./accounts) manually, and run the decryption script.
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
