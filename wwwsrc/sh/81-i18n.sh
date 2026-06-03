#!/bin/bash

for lang in en zh; do
	rsync -aupx wwwdist/prei18n/ "wwwdist/$lang/" &
done
wait


rm -r wwwdist/prei18n



find wwwdist -type f -name '*.html' | sort > .tmp/wwwdistallhtmlpathslist.txt

node wwwsrc/sh/_deps/i18n-treeshake.mjs
