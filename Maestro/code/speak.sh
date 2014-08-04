#!/bin/sh

# Force .au format for aplay to detect automatically frequency associated with voice (could be 16000hz for male or 22050hz for female)
espeak -v mb-fr4 -q --pho  "$1" | mbrola -t 1.7 -e /usr/share/mbrola/fr4/fr4 - -.au | aplay
