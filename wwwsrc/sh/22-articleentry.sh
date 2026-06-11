#!/bin/bash

### Target: /articles/{id}/


while read -r toml_path; do
	echo "toml_path=$toml_path"
	f_state="$(tomlq -r .editor.state "$toml_path")"
	if [[ "$f_state" != NewManuscript ]]; then
		(
			obj_id="$(tomlq -r .editor.obj_id "$toml_path")"
			mkdir -p wwwdist/prei18n/articles/"$obj_id"
			tomlq . "$toml_path" > wwwdist/prei18n/articles/"$obj_id"/info.json
			mustache wwwdist/prei18n/articles/"$obj_id"/info.json wwwsrc/sh/templates/article.html > wwwdist/prei18n/articles/"$obj_id"/index.html
		) &
	fi
done < <(find database -name 'info.toml' | sort -r)

wait


