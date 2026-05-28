#!/bin/bash


export PAHT="$PWD/_utils:$PATH"
export TYPST_BIN_NAME=typst

if (( $# > 1 )); then
    for target in "$@"; do
        if [[ "$PARAL" == "y" ]]; then
            "$0" "$target" &         # Run in background (parallel)
        else
            "$0" "$target" || exit $? # Run sequentially (fail-fast)
        fi
    done
    wait # Wait for all background jobs to finish if running in parallel
    exit 0
fi



case $1 in
	*.typ )
		bash _utils/ntypstpro "$1"
		;;
esac
