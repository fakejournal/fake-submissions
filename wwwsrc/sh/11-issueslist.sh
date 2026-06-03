#!/bin/bash

### Target: /issues/




### STEP: Find all non-draft issues
find pub -type f -name pub.toml | sort -r | while read -r toml_path; do
	if [[ "$(tomlq -r .issue.draft "$toml_path")" == false ]]; then
		# echo "Good! $toml_path is ok"
		echo '[[issue]]'
		linetmpl='%s = """%s"""\n'
		printf "$linetmpl" "year" "$(cut -d/ -f2 <<< "$toml_path")"
		printf "$linetmpl" "issue_id" "$(cut -d/ -f3 <<< "$toml_path")"
	fi
done > .tmp/issueslist.toml



### STEP: Finally build the website
mkdir -p wwwdist/prei18n/issues
mustache <(tomlq . .tmp/issueslist.toml) wwwsrc/sh/templates/allissues.html > wwwdist/prei18n/issues/index.html





# Test build command:
#       bash wwwsrc/sh/02-proto.sh && bash wwwsrc/sh/11-issueslist.sh
