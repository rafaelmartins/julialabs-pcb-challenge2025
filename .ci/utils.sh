set -Eeuo pipefail

function die() {
    echo "error:" "${@}" > /dev/stderr
    exit 1
}

if [[ -n "${NUM_ARGS:-}" ]] && [[ $# -lt ${NUM_ARGS:-} ]]; then
    die "invalid number of arguments"
fi

if [[ -z "${SCRIPT_DIR}" ]]; then
    die "SCRIPT_DIR not defined"
fi

ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

DEPENDENCIES="${DEPENDENCIES:-}"
if [[ "x${CI:-}" = "xtrue" ]] && [[ -n "${DEPENDENCIES}" ]]; then
    export DEBIAN_FRONTEND=noninteractive

    if [[ ! -e "${ROOT_DIR}/.apt-updated" ]]; then
        # we will need kicad anyway, lets install the ppa already
        sudo add-apt-repository -y ppa:kicad/kicad-9.0-releases 1>&2
        sudo add-apt-repository -y ppa:kicad/kicad-9.0-nightly 1>&2
        sudo apt update 1>&2
        touch "${ROOT_DIR}/.apt-updated"
    fi

    deps=()
    for dep in ${DEPENDENCIES}; do
        if [[ -z "$(apt list -qq --installed "${dep}")" ]]; then
            deps+=("${dep}")
        fi
    done

    if [[ "${#deps[@]}" -ne 0 ]]; then
        sudo apt install -y --no-install-recommends ${deps[@]} 1>&2
    fi
fi

# on MacOS we should use the python bundled with kicad app, because it includes the pcbnew modules
KICAD_MACOS_BIN="/Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/Current/bin"
if [[ "${DEPENDENCIES}" == *kicad* ]] && [[ -d "${KICAD_MACOS_BIN}" ]]; then
    export PATH="${KICAD_MACOS_BIN}:${PATH}"
fi
