#!/bin/bash
urle () { [[ "${1}" ]] || return 1; local LANG=C i x; for (( i = 0; i < ${#1}; i++ )); do x="${1:i:1}"; [[ "${x}" == [a-zA-Z0-9.~-] ]] && echo -n "${x}" || printf '%%%02X' "'${x}"; done; echo; }

manual_downloads=()

run_fetch() {
  local desc="$1"
  local target="$2"
  local url="$3"
  local type="$4"
  shift 4
  local cmd=("$@")
  if [[ "${type}" == "dir" ]]; then
    mkdir -p "${target}"
  else
    mkdir -p "$(dirname "${target}")"
  fi
  echo "Downloading ${desc}..."
  if ! "${cmd[@]}"; then
    manual_downloads+=("${desc}|${target}|${url}")
    echo "Warning: ${desc} failed. ${url} must be downloaded manually and placed under ${target}."
    return 1
  fi
  return 0
}

mdata_dir="./data/pretrain"
mkdir -p "${mdata_dir}"

# PromptHMR checkpoints
run_fetch "PromptHMR checkpoints (folder 1)" "${mdata_dir}" "https://drive.google.com/drive/folders/1EQ7arZz135T-WpxkS_K1R_hjZp3prh-y?usp=share_link" dir \
  gdown --folder -O ./data/pretrain/ https://drive.google.com/drive/folders/1EQ7arZz135T-WpxkS_K1R_hjZp3prh-y?usp=share_link
run_fetch "PromptHMR checkpoints (folder 2)" "${mdata_dir}" "https://drive.google.com/drive/folders/18SywG7Fc_iTfVNaikjHAZmy-A9I85eKv?usp=sharing" dir \
  gdown --folder -O ./data/pretrain/ https://drive.google.com/drive/folders/18SywG7Fc_iTfVNaikjHAZmy-A9I85eKv?usp=sharing

# Dataset annotations (evaluation only)
run_fetch "Evaluation annotations" "./data" "https://drive.google.com/drive/folders/1JKGXTDGaSpJ1Cp-_ikLMsw7MO7OyymIe?usp=share_link" dir \
  gdown --folder -O ./data/ https://drive.google.com/drive/folders/1JKGXTDGaSpJ1Cp-_ikLMsw7MO7OyymIe?usp=share_link

# Thirdparty checkpoints
run_fetch "Third-party checkpoints folder" "${mdata_dir}/sam2_ckpts" "https://drive.google.com/drive/folders/1OKhTdL1QVFH3f4hbIEa7jLANx4azuPi1?usp=sharing" dir \
  gdown --folder -O ./data/pretrain/sam2_ckpts/ https://drive.google.com/drive/folders/1OKhTdL1QVFH3f4hbIEa7jLANx4azuPi1?usp=sharing
run_fetch "SAM cam calibration" "${mdata_dir}/camcalib_sa_biased_l2.ckpt" "https://drive.google.com/file/d/1t4tO0OM5s8XDvAzPW-5HaOkQuV3dHBdO/view?usp=share_link" file \
  gdown --fuzzy -O ./data/pretrain/camcalib_sa_biased_l2.ckpt https://drive.google.com/file/d/1t4tO0OM5s8XDvAzPW-5HaOkQuV3dHBdO/view?usp=share_link
run_fetch "DROID-SLAM calibration" "${mdata_dir}/droidcalib.pth" "https://drive.google.com/file/d/14hgb59Jk2Pvfiqy4nntE7dUrcKgFmKSj/view?usp=share_link" file \
  gdown --fuzzy -O ./data/pretrain/droidcalib.pth https://drive.google.com/file/d/14hgb59Jk2Pvfiqy4nntE7dUrcKgFmKSj/view?usp=share_link
run_fetch "ViTPose weights" "${mdata_dir}/vitpose-h-coco_25.pth" "https://drive.google.com/file/d/1ZprPoNXe_f9a9flr0RhS3XCJBfqhFSeE/view?usp=share_link" file \
  gdown --fuzzy -O ./data/pretrain/vitpose-h-coco_25.pth https://drive.google.com/file/d/1ZprPoNXe_f9a9flr0RhS3XCJBfqhFSeE/view?usp=share_link
run_fetch "SAM weights" "${mdata_dir}/sam_vit_h_4b8939.pth" "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth" file \
  wget -O ./data/pretrain/sam_vit_h_4b8939.pth https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth

# Examples
run_fetch "Example media" "./data/examples" "https://drive.google.com/drive/folders/1uhy_8rCjOELqR9G5BXBKu0-cnQOSHFkD?usp=share_link" dir \
  gdown --folder -O ./data/examples/ https://drive.google.com/drive/folders/1uhy_8rCjOELqR9G5BXBKu0-cnQOSHFkD?usp=share_link

if [ "${#manual_downloads[@]}" -gt 0 ]; then
  echo
  echo "Manual download summary (the following entries failed and must be downloaded manually):"
  for entry in "${manual_downloads[@]}"; do
    IFS='|' read -r description location url <<< "${entry}"
    echo "- ${description}: download from ${url} and place under ${location}."
  done
  echo "If the failure was due to Google Drive rate limiting, wait ~24 hours and rerun this script or download via a browser and re-run."
else
  echo
  echo "All fetch_data downloads completed (or existed) successfully."
fi
