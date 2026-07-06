#!/bin/bash

####             bash _utils/hookdeck-daemon-start.sh



# Function to execute on SIGINT
cleanup() {
    echo "Caught SIGINT! Killing active background jobs..."
    # jobs -p lists PIDs of all active background jobs
    kill $(jobs -p) 2>/dev/null
    exit 1
}

# Trap the SIGINT signal
trap cleanup INT


export TOKEN; TOKEN="$(uuidgen v4)"
export PORT; PORT=1$(cut -c1-4 <<< "$RANDOM$RANDOM$RANDOM$RANDOM")
echo "Local port is $PORT"


node _utils/hookdeck-daemon.js &
hookdeck listen "$PORT" --output=quiet --path="/$TOKEN" github-fake-submission &

wait

