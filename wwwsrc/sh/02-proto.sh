#!/bin/bash


mkdir -p .tmp wwwsrc/sh/templates

find wwwsrc/sh/proto -name '*.html' | cut -d/ -f4 | while read -r class; do
    echo "[INFO] Working on $class ..."
    mustache .tmp/partial.json "wwwsrc/sh/proto/$class" > "wwwsrc/sh/templates/$class"
done
