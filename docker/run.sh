#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DIRNAME="$(dirname "$0")"

PARENT="$(readlink -e "$DIRNAME/..")"

docker build . -t jsonnet-md2html

docker run \
    -u "$(id -u "${USER}"):$(id -g "${USER}")" \
    --rm \
    -v "$PARENT":/training \
    -w /training \
    jsonnet-md2html make
