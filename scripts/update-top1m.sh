#!/usr/bin/env bash
set -euo pipefail

# Update Cisco Umbrella top-1m -> one domain per line (whitelist)
# Writes domains.txt in the repo root

URL="http://s3-us-west-1.amazonaws.com/umbrella-static/top-1m.csv.zip"
TMPDIR="$(mktemp -d)"
ZIP="$TMPDIR/top-1m.csv.zip"
OUT_FILE="domains.txt"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Downloading $URL ..."
# retry on transient failures
curl -fsS --retry 5 --retry-delay 3 -o "$ZIP" "$URL"

echo "Extracting and converting to one domain per line -> $OUT_FILE"
# unzip -p prints file contents to stdout; extract 2nd CSV column, clean, validate, dedupe
unzip -p "$ZIP" 2>/dev/null | \
  awk -F',' '{print $2}' | \
  tr -d '\r' | \
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
  grep -v '^$' | \
  # allow letters, digits, hyphen and dot only (conservative); adjust if you want IDNA/punycode
  grep -E '^[A-Za-z0-9.-]+$' | \
  # remove entries starting or ending with a dot
  grep -E -v '^\.' | grep -E -v '\.$' | \
  # remove consecutive dots
  grep -E -v '\.\.' | \
  # ELIMINA DUPLICADOS MANTENIENDO EL ORDEN ORIGINAL
  awk '!seen[$0]++' > "$OUT_FILE"

echo "Wrote $(wc -l < \"$OUT_FILE\") unique domains to $OUT_FILE"
