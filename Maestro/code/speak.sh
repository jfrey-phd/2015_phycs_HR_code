#!/bin/sh

# $1: sentence to be told
# $2: voice type. "F" for female, any other value for male (default)
# $3: pitch (from 0 to 99, default 50
PITCH=50
VOICE_CODE="mb-fr1"
# french mbrola voice, may vary depending on system
VOICE_PATH="/usr/share/mbrola/fr1/fr1"

# change voice for french female if flag set
if [ -n "$2" ] && [ $2 = "F" ];
then
  VOICE_CODE="mb-fr4"
  VOICE_PATH="/usr/share/mbrola/fr4/fr4"
fi

# if $3 is set and in right range select pitch
if [ -n "$3" ] && [ "$3" -ge 0 ] && [ "$3" -le 99 ];
then
    PITCH=$3
fi


# -s 120: 120 words per minute, seems more natural (default: 160 ; results sounds better than playing with "-s" parameter in mborola)
# -p : pitch variation. 50 is equivalent to "-t 1" for mbrola
# Force .au format for aplay to detect automatically frequency associated with voice (could be 16000hz for male or 22050hz for female)
espeak -s 120 -p $PITCH -v $VOICE_CODE -q --pho  "$1" | mbrola -e $VOICE_PATH - -.au | aplay
