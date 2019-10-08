#!/bin/bash

ANIM_NAME="anim-$(date +"%s").gif"
convert -delay 20 -loop 0 frames/fr-*.jpg $ANIM_NAME

if [ "$?" -eq "0" ]; then
    rm frames/fr-*.jpg
else
    echo "Dang. Sorry dude."
fi

