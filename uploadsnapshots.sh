#!/bin/bash

# Set default values for environment variables
: "${HTTP_URL:=https://webcam.connect.prusa3d.com/c/snapshot}"
: "${DELAY_SECONDS:=20}"
: "${LONG_DELAY_SECONDS:=60}"
: "${IDLE_DELAY_SECONDS:=120}"

FINGERPRINT="???"
TOKEN="???"
SNAPSHOTURL="http://127.0.0.1:8080/snapshot"

sleep "5"

source venv/bin/activate

while true; do
    now=$(date)

    response_code=$(python3 ./printer_check.py)
    #echo "$response_code was received"

    if [ "$response_code" == "PYFAIL" ]; then
        echo "$now: printer_check.py returned an error. Retrying after ${IDLE_DELAY_SECONDS}s..."

        # Set delay to the longest value
        DELAY=$IDLE_DELAY_SECONDS
    else
        #  Possible Status Codes IDLE, BUSY, PRINTING, PAUSED, FINISHED, STOPPED, ERROR, ATTENTION, READY

        if [[ "$response_code" == "IDLE" || "$response_code" == "READY" ]]; then
            echo "$now: printer_check.py showed printer is $response_code. Retrying after ${IDLE_DELAY_SECONDS}s..."

            # Set delay to the longest value
            DELAY=$IDLE_DELAY_SECONDS
        else
            echo "$now: printer_check.py showed printer is $response_code. Uploading snapshot..."

            # grab from streamer
            curl -s "$SNAPSHOTURL" -o /tmp/output.jpg

            # If no error, upload it.
            if [ $? -eq 0 ]; then
                # echo "$now: Uploading snapshot..."

                datestr=$(date)
                convert /tmp/output.jpg -quality 85 -filter lanczos -resize 800 -pointsize 18 -fill white -undercolor '#00000080' -gravity southwest -annotate +10+10 "${datestr}" /tmp/annotated.jpg

                # POST the image to the HTTP URL using curl
                curl -X PUT "$HTTP_URL" \
                    -H "accept: */*" \
                    -H "content-type: image/jpg" \
                    -H "fingerprint: $FINGERPRINT" \
                    -H "token: $TOKEN" \
                    --data-binary "@/tmp/annotated.jpg" \
                    -s \
                    --compressed

                # Reset delay to the normal value
                DELAY=$DELAY_SECONDS
            else
                echo "$now: Snapshot returned an error. Retrying after ${LONG_DELAY_SECONDS}s..."

                # Set delay to the longer value
                DELAY=$LONG_DELAY_SECONDS
            fi
        fi
    fi

    sleep "$DELAY"
done