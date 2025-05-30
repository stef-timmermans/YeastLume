# YeastLume
Repository for the YeastLume data pipeline.

## Initial Setup

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

### Prevent committing sensitive output

Add this line to your shell configuration
```shell
git config filter.strip-notebook-output.clean 'jupyter nbconvert --ClearOutputPreprocessor.enabled=True --to=notebook --stdin --stdout --log-level=ERROR'
```

[Source]()
