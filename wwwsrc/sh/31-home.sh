#!/bin/bash

### Build target: /index.html

tmp_json=".tmp/homedata.json"
echo '[]' > "$tmp_json"

### STEP: Find the last issues
find pub -type f -name pub.toml | sort -r | while read -r toml_path; do
	if [[ "$(tomlq -r .issue.draft "$toml_path")" == false ]]; then
		# echo "Good! $toml_path is ok"
		echo "$toml_path"
		break
	fi
done | head -n1 | xargs cat | tomlq | tee .tmp/lastissue.json

tomlq . wwwsrc/featured.toml > .tmp/featured.json

jq -n \
  --slurpfile list .tmp/articleslist.json \
  --slurpfile last .tmp/lastissue.json \
  --slurpfile featured .tmp/featured.json \
  '{
    list: $list[0],
    last: $last[0],
    featured: $featured[0]
  }' \
  | tee .tmp/homedata.json

mustache .tmp/homedata.json wwwsrc/sh/templates/home.html > wwwdist/index.html
