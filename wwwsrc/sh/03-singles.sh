#!/bin/bash

SINGLE_PAGES="
about
submit
submit-terms
privacy
me
"



for page_id in $SINGLE_PAGES; do
	### STEP 1: Prepare partials JSON at "$MY_PARTIAL_OUTPUT_FILE"
	MY_PARTIAL_OUTPUT_FILE=".tmp/singleHM-$page_id.json"
	jq -n \
		--rawfile head "wwwsrc/sh/partials/singleH-${page_id}.html" \
		--rawfile main "wwwsrc/sh/partials/singleM-${page_id}.html" \
		'{
			anysingle_head: $head,
			anysingle_main: $main
		}' > "$MY_PARTIAL_OUTPUT_FILE"

	### STEP 2: Render target HTML
	outdir="wwwdist/prei18n/$page_id"
	mkdir -p "$outdir"
	mustache "$MY_PARTIAL_OUTPUT_FILE" wwwsrc/sh/templates/anysingle.html > "$outdir/index.html"
done
