#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

[[ -n $(which md2html) ]] || {
    echo You need md2html from https://github.com/mity/md4c
    exit 1
}

OUTPUT="$1"

DIRNAME="$(dirname "$0")"

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

jsonnet --tla-code nav=true -J . -m "$TEMPDIR" -S main.jsonnet

FILES=$(find "$TEMPDIR" -type f -name \*.md)

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"
touch "$OUTPUT"/.nojekyll
cp -r "$DIRNAME"/assets "$OUTPUT"/assets

for f in ${FILES[@]}; do
    FILENAME=$(basename "$f")
    TITLE=$(grep '^# ' "$f"| head -1 | sed 's;^# ;;g')
    BODY=$(md2html --github "$f")
    jsonnet -S -A "title=$TITLE" -A "body=$BODY" "$DIRNAME"/html.jsonnet > "$OUTPUT/${FILENAME%.md}.html"
done

echo

for f in ${FILES[@]}; do
    FILENAME=$(basename "$f")
    find "$OUTPUT" -type f -exec sed -i "s/${FILENAME}/${FILENAME%.md}.html/" {} \;
done
