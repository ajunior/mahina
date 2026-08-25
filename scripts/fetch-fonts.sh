#!/usr/bin/env bash
# Downloads all Phosphor icon font weight files.
# Run once from the repo root: bash scripts/fetch-fonts.sh
set -e

DEST="assets/fonts"
BASE="https://github.com/phosphor-icons/web/raw/master/src"

echo "Fetching Phosphor fonts into $DEST/ ..."

curl -fsSL "$BASE/regular/Phosphor.ttf"          -o "$DEST/Phosphor-Regular.ttf"
curl -fsSL "$BASE/thin/Phosphor-Thin.ttf"        -o "$DEST/Phosphor-Thin.ttf"
curl -fsSL "$BASE/light/Phosphor-Light.ttf"      -o "$DEST/Phosphor-Light.ttf"
curl -fsSL "$BASE/bold/Phosphor-Bold.ttf"        -o "$DEST/Phosphor-Bold.ttf"
curl -fsSL "$BASE/fill/Phosphor-Fill.ttf"        -o "$DEST/Phosphor-Fill.ttf"
curl -fsSL "$BASE/duotone/Phosphor-Duotone.ttf"  -o "$DEST/Phosphor-Duotone.ttf"

echo "Done — 6 font files fetched. You can now configure and build."
