#!/bin/bash

####             bash _utils/hookdeck-daemon-start.sh

export PORT; PORT=1$(cut -c1-4 <<< "$RANDOM$RANDOM$RANDOM$RANDOM")
echo "Local port is $PORT"


node _utils/hookdeck-daemon.js &
echo hookdeck listen "$PORT" github-fake-submission

