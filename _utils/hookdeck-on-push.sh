#!/bin/bash

date -Is > /tmp/hookdeck-on-push.sh.txt


git pull &&
./make.sh wwwsrc/ &&
bash wwwsrc/cfwsdeploy.sh


