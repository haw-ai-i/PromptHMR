# PromptHMR - UV Installation Guide

This guide documents the specific steps required to set up PromptHMR using `uv` on a Linux system with CUDA 12.6, ensuring compatibility with the pre-compiled wheels in `data/wheels/`.

> [!IMPORTANT]
> All commands in this guide must be executed from the root of the `PromptHMR` repository.

## 0. Install uv
(if you don't have it)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 0.1. Add uv to path
```bash
source $HOME/.local/bin/env
```

### Video World-coordinate Reconstruction
The video pipeline requires `ffmpeg` and `ffprobe` installed on your system.

```bash
# Install system dependencies
sudo apt update && sudo apt install ffmpeg -y

```


## 1. Create Environment (Python 3.12)
The provided wheels are compiled for Python 3.12. Using Python 3.11 will result in binary incompatibility errors.

```bash
uv venv --python 3.12
source .venv/bin/activate
```

## 2. Install PyTorch and Xformers
We use PyTorch 2.6.0 and xformers 0.0.29, which are compatible with CUDA 12.6.

```bash
# Install PyTorch
uv pip install torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu126

# Install Xformers (no dependencies to avoid version conflicts)
uv pip install -U xformers==0.0.29.post2 --index-url https://download.pytorch.org/whl/cu126 --no-deps

# Install Torch-Scatter
uv pip install torch-scatter -f https://data.pyg.org/whl/torch-2.6.0+cu126.html
```

## 3. Install Requirements and Dependencies
Some legacy packages like `chumpy` require `pip` to be present in the environment for metadata generation during editable install.

```bash
# Install base requirements
uv pip install -r requirements.txt

# Install pip (required for chumpy setup)
uv pip install pip

#clone chumpy repo
git clone https://github.com/Arthur151/chumpy python_libs/chumpy

# Install chumpy in editable mode
uv pip install -e python_libs/chumpy --no-build-isolation
```

## 4. Install Pre-compiled Wheels
Install the specific wheels provided in the repository. **Note:** We must ensure only `gloss-rs` is installed (uninstall `gloss` if it was pulled in as a dependency).

```bash
# Download wheels
gdown --folder -O ./data/ https://drive.google.com/drive/folders/151gPvMaUWok_pDQT6h8Rpvk_rCcKvcWZ?usp=sharing

# Fix gloss conflict and install correct viewer
uv pip uninstall gloss gloss-rs
uv pip install data/wheels/gloss_rs-0.6.0-cp38-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

# Install other custom components
uv pip install data/wheels/detectron2-0.9-cp312-cp312-linux_x86_64.whl \
               data/wheels/droid_backends_intr-0.4-cp312-cp312-linux_x86_64.whl \
               data/wheels/sam2-1.6-cp312-cp312-linux_x86_64.whl \
               data/wheels/lietorch-0.4-cp312-cp312-linux_x86_64.whl
```

## 5. Download Body Models (SMPL/SMPL-X)
Run the fetch script and use the following credentials when prompted. Note that SMPL and SMPL-X have separate login prompts.

**Credentials:**
- **Username:** `molybog@hawaii.edu`
- **Password:** `12345678`

The credentials will be needed twice: for SMPLX and for SMPL. Use the same credentials for both.

```bash
# SMPLX family models
uv run bash scripts/fetch_smplx.sh

# Checkpoints and annotations
uv run bash scripts/fetch_data.sh
```

## 6. Run the Demos

### Single View Reconstruction
```bash
uv run scripts/demo_phmr.py --image data/examples/example_1.jpg --gravity_align
```



