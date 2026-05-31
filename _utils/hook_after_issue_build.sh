#!/usr/bin/env bash
set -euo pipefail

issue_dir="$1"
pdf_path="_dist/$issue_dir/issue.pdf"

du -h "$pdf_path"

pub_toml="$(<"$issue_dir/pub.toml")"

arrsize="$(tomlq -r '.article | length' <<<"$pub_toml")"

for ((idx=0; idx<arrsize; idx++)); do
    echo "idx=$idx"

    range_from="$(tomlq -r ".article[$idx].range_from" <<<"$pub_toml")"
    range_to="$(tomlq -r ".article[$idx].range_to" <<<"$pub_toml")"
    obj_dir="$(tomlq -r ".article[$idx].path" <<<"$pub_toml")"

    final_pdf_path="_dist/$obj_dir/final.pdf"

    mkdir -p "$(dirname "$final_pdf_path")"

    pdftk "$pdf_path" \
        cat "$range_from-$range_to" \
        output "$final_pdf_path" &
done

wait
