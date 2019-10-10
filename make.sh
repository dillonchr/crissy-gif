#!/bin/bash

if [ ! -d "frames" ]; then
    mkdir frames
fi

COUNT="10"
if [ "$#" -gt "0" ]; then
    COUNT="$1"
fi
ID="$(curl -s http://173.164.254.148/ptz.cgi\?doc\=East%20Beach%20Webcam\&xml\=1\&cmd\=open\&version\=20100917\&kind\=ctl | egrep -o 'key="id" value="([A-Z0-9_]+)"' | sed -n -E 's/.*value="([^"]+)"/\1/p')"
URL="http://173.164.254.148/vid.cgi?id=${ID}&doc=East%20Beach%20Webcam&i=1"

# Author : Teddy Skarin
function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _done=$(printf "%${_done}s")
    _left=$(printf "%${_left}s")
    printf "\r [${_done// /=}${_left// / }] ${_progress}%%"
}

if [ "$?" -eq "0" ]; then
    for ((i=1; i<=COUNT; i++));
    do
        curl -s "${URL}&r=${RANDOM}" > "frames/fr-$(date +"%s")-${i}.jpg"
        if [ ! "$?" -eq "0" ]; then
            echo "Failed to download /shrug"
            exit 2
        fi
        ProgressBar ${i} ${COUNT}
    done

    ANIM_NAME="anim-$(date +"%s").gif"
    convert -delay 20 -loop 0 frames/fr-*.jpg $ANIM_NAME

    if [ "$?" -eq "0" ]; then
        rm frames/fr-*.jpg
        open -a "Google Chrome" "file://${PWD}/${ANIM_NAME}"
    else
        echo "Dang. Sorry dude."
    fi
else
    echo "Sorry dude."
fi
