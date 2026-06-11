#!/bin/bash

function make_news_item() {
	local fn="$1"
	local sep_row_num="$(grep -n -m 1 "^+++$" "$fn" | cut -d: -f1)"
	local total_lines="$(wc -l < "$fn")"
	local base="${fn##*/}"
	local item_id="${base%%-*}"
	# echo "($fn) sep_row_num = $sep_row_num"
	# echo "($fn) total_lines = $total_lines"
	# echo "($fn) item_id = $item_id"
	local dirpath="wwwdist/prei18n/news/$item_id"
	mkdir -p "$dirpath"
	echo TOML ================================
	local news_toml="$(head -n $((sep_row_num - 1)) "$fn")"
	tomlq <<< "$news_toml" > "$dirpath/news_item.json"
	echo CONTENT =============================
	local news_body="$(tail -n $((total_lines - sep_row_num)) "$fn")"
	### ================
	### TODO: Use jq to add {body: "$news_body"} to "$dirpath/news_item.json"
	jq --arg body "$news_body" '. + {body: $body}' \
		"$dirpath/news_item.json" > "$dirpath/news_item.json.tmp" &&
	mv "$dirpath/news_item.json.tmp" "$dirpath/news_item.json"
	echo write to "$dirpath/index.html"
	mustache "$dirpath/news_item.json" wwwsrc/sh/templates/news.html > "$dirpath/index.html"
}
export -f make_news_item

# find wwwsrc/news -name '*.html' | parallel -j12 make_news_item {}


max_jobs=8
while read -r fn; do
    make_news_item "$fn" &
    while (( $(jobs -pr | wc -l) >= max_jobs )); do
        wait -n
    done
done < <(find wwwsrc/news -name '*.html')
wait


# find wwwdist -name news_item.json | sort -r | while read -r json; do
# 	echo json = "$json"
# done

find wwwdist/prei18n -name news_item.json | sort -r | xargs jq -s '.' > wwwdist/prei18n/_newslist.json

cat wwwdist/prei18n/_newslist.json

mustache wwwdist/prei18n/_newslist.json wwwsrc/sh/templates/newslist.html > "wwwdist/prei18n/news/index.html"
