#!/bin/bash

### Target: /issues/



# function buildissuedetailpage() {
# 	local toml_path="$1"
# 	### TODO:
# 	### List all articles at '.issue.article[]'
# 	### In each article item, 'path' is like "database/2022/2022.3170411"
# 	### get obj_id by `cut -d/ -f3 <<< $path`
# 	### Find article metadata TOML at "$path/info.toml"
# 	### Aggregate all these TOML
# 	### Final issue-defining JSON should be like {pub: {}, info:[]} where pub is read from $toml_path and info[] is the list of parsed 'info.toml'
# 	### Save the final JSON at "wwwdist/issues/$(dut -d/ -f3 <<< "$toml_path")/issue.json"
# }



function buildissuedetailpage() {
	local toml_path="$1"

	# Read publication TOML as JSON
	local pub_json
	pub_json="$(tomlq -c . "$toml_path")" || return 1

	# Collect article metadata JSON objects
	local info_json
	info_json="$(
		tomlq -r '.article[].path' "$toml_path" |
		while read -r path; do
			local obj_id
			obj_id="$(cut -d/ -f3 <<< "$path")"

			local info_toml="$path/info.toml"
			[ -f "$info_toml" ] || continue

			tomlq -c . "$info_toml"
		done |
		jq -s .
	)" || return 1

	# Build final document
	local issue_json
	issue_json="$(
		jq -n \
			--argjson pub "$pub_json" \
			--argjson info "$info_json" \
			'{pub:$pub, info:$info}'
	)" || return 1

	local issue_id
	issue_id="$(cut -d/ -f3 <<< "$toml_path")"

	local outdir="wwwdist/issues/$issue_id"
	mkdir -p "$outdir"

	printf '%s\n' "$issue_json" > "$outdir/issue.json"
	mustache "$outdir/issue.json" "wwwsrc/sh/templates/issue.html" > "$outdir/index.html"
}


### STEP: Find all non-draft issues
find pub -type f -name pub.toml | sort -r | while read -r toml_path; do
	if [[ "$(tomlq -r .issue.draft "$toml_path")" == false ]]; then
		# echo "Good! $toml_path is ok"
		( buildissuedetailpage "$toml_path" ) &
	fi
done

wait
