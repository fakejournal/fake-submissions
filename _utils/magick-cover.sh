#!/bin/bash

magick "$1" -resize 1100x1100^ -gravity Center -extent 1100x1100 "$(sed 's/-raw//' <<< "$1")"
