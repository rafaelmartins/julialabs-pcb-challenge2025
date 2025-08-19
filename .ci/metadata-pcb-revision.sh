#!/bin/bash

NUM_ARGS=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

exec grep "(rev " "${1}" | sed 's/.*rev "\([0-9.]*\)".*/\1/'
