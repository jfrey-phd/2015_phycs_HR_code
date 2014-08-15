#!/bin/sh

# $1: sentence to be told
# $2: voice type. "FEMALE" for female, any other value for male (default)
# $3: voice number (default for male: fr1, for female: fr4). Only value handled: 0 or 1
# $4: pitch (from 0 to 99, default 50
PITCH=50
VOICE_CODE="mb-fr1"
# french mbrola voice, location may vary depending on system
VOICE_PATH="/usr/share/mbrola/fr1/fr1"
GENDER="MALE"

# change voice for french female if flag set
if [ -n "$2" ] && [ $2 = "FEMALE" ];
then
  GENDER="FEMALE"
  VOICE_CODE="mb-fr4"
  VOICE_PATH="/usr/share/mbrola/fr4/fr4"
fi

# change voice number for alternative if $3 is set and different than 0
# Since we handle only 2 voices, "1" will set the alternative voice, every other value leave to default
if [ -n "$3" ] && [ "$3" -eq 1 ];
then
  # NB. espeak only knows about male/female voice code, the correct voice number is for mbrola
  if [ $GENDER = "MALE" ]
  then
    VOICE_PATH="/usr/share/mbrola/fr3/fr3"
  else
    VOICE_PATH="/usr/share/mbrola/fr2/fr2"
  fi
fi

# if $4 is set and in right range select pitch
if [ -n "$4" ] && [ "$4" -ge 0 ] && [ "$4" -le 99 ];
then
    PITCH=$4
fi

# -s 120: 120 words per minute, seems more natural (default: 160 ; results sounds better than playing with "-s" parameter in mborola)
# -p : pitch variation. 50 is equivalent to "-t 1" for mbrola
# Force .au format for aplay to detect automatically frequency associated with voice (could be 16000hz for male or 22050hz for female)
espeak -s 120 -p $PITCH -v $VOICE_CODE -q --pho  "$1" | mbrola -e $VOICE_PATH - -.au | aplay

