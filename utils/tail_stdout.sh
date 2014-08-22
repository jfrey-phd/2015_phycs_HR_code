#!/bin/sh

#ssh pimousse tail -f "~/HR/repo/recordings/*.txt"

# filter pulse feedback, too many output otherwise
ssh 192.168.5.1 tail -f "~/HR/repo/recordings/*.txt" | grep -v -e HeartManager -e OVTK_GDF_Artifact_Pulse


