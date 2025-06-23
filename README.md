# YeastLume
Repository for the YeastLume data pipeline.

---

## Initial Setup
Run the setup script for the repository. The script will exit on failure and assumes that Python, Pip, Conda, and Git are installed.
```shell
./setup.sh
```

---

## Remote Data Hosting via DVC
Hosting the training data can be done however you please, however this project was developed using Data Version Control (DVC) with Google Cloud Platform. In order to correctly setup Google Drive as a storage space in a headless environment, ensure the following steps are taken on a **new fork** of the repository:

1. Create a new Google Cloud Platform project
2. Under "APIs and Services" → "Enabled APIs & services", click "+ Enable APIs and services" and search for and enable the Google Drive API.
3. Go to "APIs and Services" → "Credentials" and configure a basic consent screen. Configure for internal use unless deploying a public-facing pipeline.
4. Under "APIs and Services" → "Credentials", click "+ Create credentials" and select for service accounts. Configure account to be an Editor or Owner.
5. Click on the created service account email and go to "Keys" and click "Add key" to create a new JSON key.

## Manual Setup

**All setup instructions are optimized for and assuming macOS/Linux.**

### Starting a Virtual Environment

1. Create/refresh a virtual environment
```shell
rm -r venv
python3 -m venv .venv
```

2. Activate the virtual environment
```shell
source .venv/bin/activate
```

3. Install the requirements file
```shell
pip install -r requirements.txt
```

---

### Prevent committing sensitive output

Add this line to your shell configuration:
```shell
git config filter.strip-notebook-output.clean 'jupyter nbconvert --ClearOutputPreprocessor.enabled=True --to=notebook --stdin --stdout --log-level=ERROR'
```

**[Source](https://gist.github.com/33eyes/431e3d432f73371509d176d0dfb95b6e)**
