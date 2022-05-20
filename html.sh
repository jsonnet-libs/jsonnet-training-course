#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

TEMPDIR=$(mktemp -d)

jsonnet --tla-code html=true -J . -m ${TEMPDIR} -S main.jsonnet

FILES=$(find ${TEMPDIR} -type f -name \*.md)

rm -rf _html
mkdir -p _html

for f in ${FILES[@]}; do
    FILENAME=$(basename $f)
    md2html -f --github $f -o _html/${FILENAME%.md}.html
    TITLE=$(grep '<h1>' _html/${FILENAME%.md}.html|sed 's;<\(/\?\)h1>;<\1title>;g')
    sed -i "s;<title></title>;$TITLE;" _html/${FILENAME%.md}.html
done

for f in ${FILES[@]}; do
    FILENAME=$(basename $f)
    find _html -type f | xargs sed -i "s/${FILENAME}/${FILENAME%.md}.html/"
done
