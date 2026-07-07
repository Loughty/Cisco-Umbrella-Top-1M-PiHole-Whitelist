#!/usr/bin/env bash
set -euo pipefail

# Update Cisco Umbrella top-1m -> one domain per line (whitelist)
URL="http://s3-us-west-1.amazonaws.com/umbrella-static/top-1m.csv.zip"
TMPDIR="$(mktemp -d)"
ZIP="$TMPDIR/top-1m.csv.zip"

# Definimos los tres archivos de salida
OUT_1M="umbrella-top-1m.txt"
OUT_500K="umbrella-top-500k.txt"
OUT_100K="umbrella-top-100k.txt"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Downloading $URL ..."
curl -fsS --retry 5 --retry-delay 3 -o "$ZIP" "$URL"

echo "Extracting and converting to one domain per line..."
# Procesamos la lista completa limpia y ordenada por popularidad
unzip -p "$ZIP" 2>/dev/null | \
  awk -F',' '{print $2}' | \
  tr -d '\r' | \
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
  grep -v '^$' | \
  grep -E '^[A-Za-z0-9.-]+$' | \
  grep -E -v '^\.' | grep -E -v '\.$' | \
  grep -E -v '\.\.' | \
  awk '!seen[$0]++' > "$OUT_1M"

# Generamos las sublistas basadas en el archivo principal
echo "Creating sub-lists (Top 500k and Top 100k)..."
head -n 500000 "$OUT_1M" > "$OUT_500K"
head -n 100000 "$OUT_1M" > "$OUT_100K"

echo "Wrote $(wc -l < "$OUT_1M") domains to $OUT_1M"
echo "Wrote $(wc -l < "$OUT_500K") domains to $OUT_500K"
echo "Wrote $(wc -l < "$OUT_100K") domains to $OUT_100K"
