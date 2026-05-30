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


function _die() {
	echo "$2"
	exit "$1"
}


case $1 in
	*.typ )
		bash _utils/ntypstpro "$1"
		;;
	init )
		command -v yarn > /dev/null 2>&1 || _die 1 "[ERROR] You must install 'yarn'."
		yarn
		bash _utils/fontsdep.sh i
		rm -rf "_fontsdir/6deb0a88-1.422.zip.d/barlow-1.422/fonts/"{gx,ttf}
		;;
esac
