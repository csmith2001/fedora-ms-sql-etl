#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
DATA_DIR="$ROOT_DIR/Data/"

KAGGLE_API="v1/"
KAGGLE_URL="https://www.kaggle.com/api/${KAGGLE_API}datasets/download/"

readonly SCRIPT_DIR
readonly ROOT_DIR
readonly DATA_DIR
readonly KAGGLE_API
readonly KAGGLE_URL
# **********************************************************************
read -rp "Enter kaggle dataset URL: " data_url
if [[ ! "$data_url" =~ kaggle\.com/datasets/([^/]+)/([^/?]+)$ ]]; then
    printf 'Invalid Kaggle dataset URL!\n'
    exit 1
fi

owner_slug="${BASH_REMATCH[1]}"
dataset_slug="${BASH_REMATCH[2]}"

tmp_zip="/tmp/${dataset_slug}.zip"
target_dir="${DATA_DIR}${dataset_slug}"
download_url="${KAGGLE_URL}${owner_slug}/${dataset_slug}"

curl -Ls -o "$tmp_zip" "$download_url"
mkdir -p "$target_dir"

printf 'Extracting dataset...\n'
if ! unzip -q -o "$tmp_zip" -d "$target_dir" >/dev/null; then
    printf 'Failed to extract dataset!\n'
    exit 1
fi

rm -f "$tmp_zip"
printf 'Dataset extracted to: %s\n' "$target_dir"
