#!/usr/bin/env bash
set -euo pipefail

CONFIG="config.json"

echo "Processing styles"
STYLES="styles/*"

MBTILE_KEY=$(jq --raw-output '.["data"] | keys[0]' "${CONFIG}")
echo "MBTILE to use: ${MBTILE_KEY}"

for STYLE in $STYLES; do
  STYLE_NAME="${STYLE##*/}"
  STYLE_NAME="${STYLE_NAME%.*}"
  echo "Processing ${STYLE} -- ${STYLE_NAME}"

  jq ".sources.openmaptiles.url = \"mbtiles://{${MBTILE_KEY}}\" | (.sprite | select(.) ) = \"${STYLE_NAME}\" | .glyphs = \"{fontstack}/{range}.pbf\"" \
    "${STYLE}" > "${STYLE}.temp"
  mv "${STYLE}.temp" "${STYLE}"

  echo "Updating config"
  jq ".styles += {\"${STYLE_NAME}\": { \"style\": \"${STYLE_NAME}.json\"}}" "${CONFIG}" > "${CONFIG}.tmp"
  mv "${CONFIG}.tmp" "${CONFIG}"
done

cat "${CONFIG}"
