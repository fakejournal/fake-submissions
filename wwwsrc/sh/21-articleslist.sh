#!/bin/bash

mkdir -p .tmp
### Target: /articles/

tmp_json=".tmp/articleslist.json"
echo '[]' > "$tmp_json"

find database -name 'info.toml' | sort -r | while read -r toml_path; do
	f_state="$(tomlq -r .editor.state "$toml_path")"

	if [[ "$f_state" != NewManuscript ]]; then
		obj_dir="$(dirname "$toml_path")"

		tomlq . "$toml_path" |
			jq --arg obj_dir "$obj_dir" '
				. + {obj_dir: $obj_dir}
			' |
			jq -s '.[0] + [.[1]]' "$tmp_json" - \
			> "$tmp_json.tmp" &&
			mv "$tmp_json.tmp" "$tmp_json"
	fi
done

# cat .tmp/articleslist.json
# echo cat .tmp/articleslist.json

mkdir -p wwwdist/prei18n/articles
mustache .tmp/articleslist.json wwwsrc/sh/templates/articleslist.html > wwwdist/prei18n/articles/index.html
