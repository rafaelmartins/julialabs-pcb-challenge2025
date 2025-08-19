#!/bin/bash

PCB_RENDER_ZOOM=0.95
PCB_RENDER_PAN=0,0,0
PCB_RENDER_ROTATE=0,0,0
PCB_RENDER_WIDTH=4320
PCB_RENDER_HEIGHT=4000

NUM_ARGS=1
DEPENDENCIES="kicad kicad-libraries kicad-footprints kicad-packages3d imagemagick"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

NAME="business-card-synth"
OUTPUT_DIR="$(mkdir -p "${1}"; realpath "${1}")"

mkdir -p "${OUTPUT_DIR}"

function resize() {
    convert \
        "${1}" \
        -resize "${2}x${2}^" \
        "${1/.png/_${2}.png}"
}

function render() {
    local side
    case "${1}" in
        front)
            side=top
            ;;
        back)
            side=bottom
            ;;
        *)
            die "unsupported side: ${1}"
    esac

    kicad-cli \
        pcb render \
            --output "${OUTPUT_DIR}/${NAME}-${1}.png" \
            --background opaque \
            --zoom "${PCB_RENDER_ZOOM}" \
            --pan "'${PCB_RENDER_PAN}'" \
            --rotate "'${PCB_RENDER_ROTATE}'" \
            --width "${PCB_RENDER_WIDTH}" \
            --height "${PCB_RENDER_HEIGHT}" \
            --side "${side}" \
            "${ROOT_DIR}/pcb/${NAME}.kicad_pcb"

    resize "${OUTPUT_DIR}/${NAME}-${1}.png" 480
    resize "${OUTPUT_DIR}/${NAME}-${1}.png" 720
    resize "${OUTPUT_DIR}/${NAME}-${1}.png" 1080
}

render front
render back

montage \
    "${OUTPUT_DIR}/${NAME}-front.png" \
    "${OUTPUT_DIR}/${NAME}-back.png" \
    -tile 1x2 \
    -geometry +0+0 \
    "${OUTPUT_DIR}/${NAME}.png"

resize "${OUTPUT_DIR}/${NAME}.png" 480
resize "${OUTPUT_DIR}/${NAME}.png" 720
resize "${OUTPUT_DIR}/${NAME}.png" 1080

rm "${OUTPUT_DIR}/${NAME}.png"
rm "${OUTPUT_DIR}/${NAME}-front.png"
rm "${OUTPUT_DIR}/${NAME}-back.png"

kicad-cli \
    sch export pdf \
        --output "${OUTPUT_DIR}/${NAME}.pdf" \
        "${ROOT_DIR}/pcb/${NAME}.kicad_sch"

export INTERACTIVE_HTML_BOM_NO_DISPLAY=1
python3 "${ROOT_DIR}/../InteractiveHtmlBom/InteractiveHtmlBom/generate_interactive_bom.py" \
    --no-browser \
    --dest-dir "${OUTPUT_DIR}" \
    --name-format "%f" \
    --include-tracks \
    --include-nets \
    --blacklist "H*" \
    "${ROOT_DIR}/pcb/${NAME}.kicad_pcb"
