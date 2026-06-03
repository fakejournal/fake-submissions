#!/bin/bash

### Target: /tracker/{id}/


find database -name 'info.toml' | sort -r | while read -r toml_path; do
	(
		# echo "toml_path=$toml_path"
		obj_id="$(tomlq -r .editor.obj_id "$toml_path")"
		mkdir -p wwwdist/prei18n/tracker/"$obj_id"
		(
			cat "$toml_path"
			echo ""
			cat "$(dirname "$toml_path")/tracker.toml"
		) | tomlq > ".tmp/tracker-$obj_id.json"
		mustache ".tmp/tracker-$obj_id.json" wwwsrc/sh/templates/tracker.html > wwwdist/prei18n/tracker/"$obj_id"/index.html
	) &
done

wait
