set -xue
F="$1"
BASE="${1%.*}"
EXT="${1##*.}"

avconv -i "$F" -c:a copy "${BASE}-fixed.${EXT}"
