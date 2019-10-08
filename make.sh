#!/bin/bash

ID="$(curl -s http://173.164.254.148/ptz.cgi\?doc\=East%20Beach%20Webcam\&xml\=1\&cmd\=open\&version\=20100917\&kind\=ctl | egrep -o 'key="id" value="([A-Z0-9_]+)"' | sed -n -E 's/.*value="([^"]+)"/\1/p')"
URL="http://173.164.254.148/vid.cgi?id=${ID}&doc=East%20Beach%20Webcam&i=1"

if [ "$?" -eq "0" ]; then
    for i in {1..10}
    do
        start="$(date +"%s")"
        curl -s "${URL}&r=${RANDOM}" > "frames/fr-$(date +"%s").jpg"
        fin="$(date +"%s")"
        result=$((fin - start))
        if [ "$result" -lt "1" ]; then
            sleep 1
        fi
    done

    ANIM_NAME="anim-$(date +"%s").gif"
    convert -delay 20 -loop 0 frames/fr-*.jpg $ANIM_NAME

    if [ "$?" -eq "0" ]; then
        rm frames/fr-*.jpg
    else
        echo "Dang. Sorry dude."
    fi
else
    echo "Sorry dude."
fi
