#!/bin/bash

git pull &&
./make.sh wwwsrc/ &&
bash wwwsrc/cfwsdeploy.sh
