#!/bin/bash
# Set default values for environment variables

#Prusa Connect Values
export HTTP_URL=https://webcam.connect.prusa3d.com/c/snapshot
export FINGERPRINT=???
export TOKEN=???

#Camera Streamer Values
export SNAPSHOTURL=http://127.0.0.1:8080/snapshot

#Variable Delay Values
export START_DELAY_SECONDS=5
export DELAY_SECONDS=20
export LONG_DELAY_SECONDS=60
export IDLE_DELAY_SECONDS=120

#Debug/Testing Values
export FORCE_RUN=true

#enter the python venv before running script
source venv/bin/activate

#Run the Sub Script to Loop Snapshot Uploads
cd 3dprinter-camera-streamer
./uploadsnapshots.sh
