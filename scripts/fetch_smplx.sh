#!/bin/bash
urle () { [[ "${1}" ]] || return 1; local LANG=C i x; for (( i = 0; i < ${#1}; i++ )); do x="${1:i:1}"; [[ "${x}" == [a-zA-Z0-9.~-] ]] && echo -n "${x}" || printf '%%%02X' "'${x}"; done; echo; }

manual_downloads=()

run_fetch() {
  local desc="$1"
  local target="$2"
  local url="$3"
  shift 3
  echo "Downloading ${desc}..."
  if ! "$@"; then
    manual_downloads+=("${desc}|${target}|${url}")
    echo "Warning: ${desc} failed. ${url} must be downloaded manually and placed under ${target}."
    return 1
  fi
  return 0
}

echo -e "\nYou need to register at https://smpl-x.is.tue.mpg.de"
read -p "Username (SMPL-X):" username
read -p "Password (SMPL-X):" password
username=$(urle $username)
password=$(urle $password)

mkdir -p data/body_models
smplx_zip="./data/body_models/smplx.zip"
run_fetch "SMPLX model archive" "${smplx_zip}" "https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=models_smplx_v1_1.zip" \
  wget --post-data "username=$username&password=$password" 'https://download.is.tue.mpg.de/download.php?domain=smplx&sfile=models_smplx_v1_1.zip' -O "${smplx_zip}" --no-check-certificate --continue
if [ -f "${smplx_zip}" ]; then
  unzip "${smplx_zip}" -d data/body_models/smplx
  mv data/body_models/smplx/models/smplx/* data/body_models/smplx/
  rm -rf data/body_models/smplx/models
  rm -f "${smplx_zip}"
else
  echo "Skipping SMPLX extraction because ${smplx_zip} is missing."
fi

echo -e "\nYou need to register at https://smpl.is.tue.mpg.de"
read -p "Username (SMPL):" username
read -p "Password (SMPL):" password
username=$(urle $username)
password=$(urle $password)

mkdir -p data/body_models/smpl
smpl_zip="./data/body_models/smpl/smpl.zip"
run_fetch "SMPL Python archive" "${smpl_zip}" "https://download.is.tue.mpg.de/download.php?domain=smpl&sfile=SMPL_python_v.1.1.0.zip" \
  wget --post-data "username=$username&password=$password" 'https://download.is.tue.mpg.de/download.php?domain=smpl&sfile=SMPL_python_v.1.1.0.zip' -O "${smpl_zip}" --no-check-certificate --continue
if [ -f "${smpl_zip}" ]; then
  unzip "${smpl_zip}" -d data/body_models/smpl/smpl
  mv data/body_models/smpl/smpl/SMPL_python_v.1.1.0/smpl/models/basicmodel_neutral_lbs_10_207_0_v1.1.0.pkl data/body_models/smpl/SMPL_NEUTRAL.pkl
  mv data/body_models/smpl/smpl/SMPL_python_v.1.1.0/smpl/models/basicmodel_f_lbs_10_207_0_v1.1.0.pkl data/body_models/smpl/SMPL_FEMALE.pkl
  mv data/body_models/smpl/smpl/SMPL_python_v.1.1.0/smpl/models/basicmodel_m_lbs_10_207_0_v1.1.0.pkl data/body_models/smpl/SMPL_MALE.pkl
  rm -rf data/body_models/smpl/smpl
  rm -f "${smpl_zip}"
else
  echo "Skipping SMPL extraction because ${smpl_zip} is missing."
fi

# Supplementary files
run_fetch "SMPL supplementary folder" "./data" "https://drive.google.com/drive/folders/1JU7CuU2rKkwD7WWjvSZJKpQFFk_Z6NL7?usp=share_link" \
  gdown --folder -O ./data/ https://drive.google.com/drive/folders/1JU7CuU2rKkwD7WWjvSZJKpQFFk_Z6NL7?usp=share_link
run_fetch "SMPLX extra asset" "./data/body_models/smplx" "https://drive.google.com/file/d/1v9Qy7ZXWcTM8_a9K2nSLyyVrJMFYcUOk" \
  gdown -O ./data/body_models/smplx/ 1v9Qy7ZXWcTM8_a9K2nSLyyVrJMFYcUOk

if [ "${#manual_downloads[@]}" -gt 0 ]; then
  echo
  echo "Manual download summary (the following entries failed and must be downloaded manually):"
  for entry in "${manual_downloads[@]}"; do
    IFS='|' read -r description location url <<< "${entry}"
    echo "- ${description}: download from ${url} and place under ${location}."
  done
  echo "If the failure was due to rate limiting or credentials, rerun this script after ensuring the file exists locally or download via a browser and rerun."
else
  echo
  echo "All fetch_smplx downloads completed (or were already satisfied)."
fi
