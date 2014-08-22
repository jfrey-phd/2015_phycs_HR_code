#!/bin/sh

ssh 192.168.5.1 tail -f "~/HR/repo/recordings/*.txt" | grep $StageXP.createAgent

