#!/bin/bash

NUM_ARGS=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/utils.sh"

OUTPUT_DIR="$(mkdir -p "${1}"; realpath "${1}")"
NAME="business-card-synth"

MYTMPDIR="$(mktemp -d)"
trap 'rm -rf -- "${MYTMPDIR}"' EXIT

if [[ "x${CI:-}" = "xtrue" ]]; then
    "${SCRIPT_DIR}/patch-render-config.sh"
fi

cat > "${OUTPUT_DIR}/index.html" <<EOF
<html>
  <head><title>${NAME}</title></head>
  <body>
    <h1>${NAME}</h1>
EOF

pushd "${MYTMPDIR}" > /dev/null

"${SCRIPT_DIR}/build-pcb-assets.sh" \
    ./out

mv \
    -v \
    out/* \
    "${OUTPUT_DIR}/"

cat >> "${OUTPUT_DIR}/index.html" <<EOF
    <img src="./${NAME}_480.png">
    <ul>
      <li><a href="./${NAME}.html">Interactive Bill of Materials</a></li>
      <li><a href="./${NAME}.pdf">Schematics</a></li>
      <li><a href="./${NAME}_1080.png">3D Render (Front/Back, 1080p)</a></li>
      <li><a href="./${NAME}_720.png">3D Render (Front/Back, 720p)</a></li>
      <li><a href="./${NAME}_480.png">3D Render (Front/Back, 480p)</a></li>
      <li><a href="./${NAME}-front_1080.png">3D Render (Front, 1080p)</a></li>
      <li><a href="./${NAME}-front_720.png">3D Render (Front, 720p)</a></li>
      <li><a href="./${NAME}-front_480.png">3D Render (Front, 480p)</a></li>
      <li><a href="./${NAME}-back_1080.png">3D Render (Back, 1080p)</a></li>
      <li><a href="./${NAME}-back_720.png">3D Render (Back, 720p)</a></li>
      <li><a href="./${NAME}-back_720.png">3D Render (Back, 480p)</a></li>
    </ul>
EOF

popd > /dev/null

cat >> "${OUTPUT_DIR}/index.html" <<EOF
  </body>
</html>
EOF
