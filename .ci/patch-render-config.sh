#!/bin/bash

NUM_ARGS=0
DEPENDENCIES="kicad"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

SOURCE_DIR="$(realpath "${ROOT_DIR}")"

# render something to ensure the config exists

PCB="$(find . -iname \*.kicad_pcb | head -n1)"
if [[ -z "${PCB}" ]]; then
    die "no pcb found"
fi

kicad-cli \
    pcb render \
        --output /tmp/dummy.jpg \
        "${PCB}"

cp -v ~/.config/kicad/9.0/3d_viewer.json{,.bkp}
cp -v ~/.config/kicad/9.0/3d_viewer.json /tmp/3d_viewer.json

jq \
    '.render.show_footprints_dnp = true | .render.show_comments = false | .render.show_drawings = false' \
    /tmp/3d_viewer.json \
    > ~/.config/kicad/9.0/3d_viewer.json
