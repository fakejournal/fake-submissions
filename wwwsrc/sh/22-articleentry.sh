#!/bin/bash

### Target: /articles/{id}/


find database -name 'info.toml' | sort -r | while read -r toml_path; do
	echo "toml_path=$toml_path"
	f_state="$(tomlq -r .editor.state "$toml_path")"
	if [[ "$f_state" != NewManuscript ]]; then
		(
			obj_id="$(tomlq -r .editor.obj_id "$toml_path")"
			mkdir -p wwwdist/articles/"$obj_id"
			tomlq . "$toml_path" > wwwdist/articles/"$obj_id"/info.json
			mustache wwwdist/articles/"$obj_id"/info.json wwwsrc/sh/templates/article.html > wwwdist/articles/"$obj_id"/index.html
		) &
	fi
done

wait


