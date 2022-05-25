#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

TEMPDIR=$(mktemp -d)
function finish {
    rm -rf "${TEMPDIR}"
}
trap finish EXIT

jsonnet --tla-code nav=true -J . -m "${TEMPDIR}" -S main.jsonnet

FILES=$(find "${TEMPDIR}" -type f -name \*.md)

rm -rf _html
mkdir -p _html
cp -r assets _html/assets

for f in ${FILES[@]}; do
    FILENAME=$(basename "$f")
    TITLE=$(grep '^# ' "$f"| head -1 | sed 's;^# ;;g')
    BODY=$(md2html --github "$f")
    jsonnet -S -A "title=$TITLE" -A "body=$BODY" html.jsonnet > "_html/${FILENAME%.md}.html"
done

echo

for f in ${FILES[@]}; do
    FILENAME=$(basename "$f")
    find _html -type f -exec sed -i "s/${FILENAME}/${FILENAME%.md}.html/" {} \;
done
