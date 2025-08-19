#!/bin/bash

NUM_ARGS=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

OUTPUT_DIR="$(mkdir -p "${1}"; realpath "${1}")"

function _git() {
    git \
        --git-dir="${ROOT_DIR}/.git" \
        --work-tree="${ROOT_DIR}" \
        "${@}"
}

for rev in $(_git tag | grep -E "^(f0|g4)/"); do
    mkdir -p "${OUTPUT_DIR}/${rev}"

    _git archive \
        --format tar \
        "${rev}" \
    | tar \
        --extract \
        --verbose \
        --file=- \
        -C "${OUTPUT_DIR}/${rev}"
done
