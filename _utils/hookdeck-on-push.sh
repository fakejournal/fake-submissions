#!/bin/bash

date -Is > /tmp/hookdeck-on-push.sh.txt


retry() {
    local max=$1
    shift

    local i
    for ((i=1; i<=max; i++)); do
        "$@" && return 0
        (( i == max )) && return 1
        sleep 5
    done
}

retry 10 git pull &&
./make.sh wwwsrc/ &&
bash wwwsrc/cfwsdeploy.sh


