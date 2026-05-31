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
		pdfpath="_dist/$(dirname "$1")/$(basename -s .typ "$1" ).pdf"
		echo "PDF path: $pdfpath"
		bash "$0" "$pdfpath"
		case $1 in
			pub/*/issue.typ )
				echo "(HINT)  You may want to also run:  " bash _utils/hook_after_issue_build.sh "$(dirname "$1")"
				;;
		esac
		;;
	_dist/database/*/_cover.pdf )
		pdftoppm -r 150 -png -singlefile "$1" "$1"
		du -h "$(realpath "$1.png")"
		;;
	_dist/pub/*/issue.pdf )
		pdftoppm -r 100 -png -singlefile "$1" "$1"
		du -h "$(realpath "$1.png")"
		;;
	wwwsrc/ )
		echo "[INFO] Building website..."
		find wwwsrc/sh -name "*.sh" | sort | while read -r script_path; do
			bash "$script_path"
		done
		echo "(HINT)  You may want to also run:  " bash wwwsrc/cfwsdeploy.sh
		;;
	init )
		command -v yarn > /dev/null 2>&1 || _die 1 "[ERROR] You must install 'yarn'."
		yarn
		bash _utils/fontsdep.sh i
		rm -rf "_fontsdir/6deb0a88-1.422.zip.d/barlow-1.422/fonts/"{gx,ttf}
		;;
esac
