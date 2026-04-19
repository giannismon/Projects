#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
URL="<YOUR_URL>"
STATUS_FILE="$SCRIPT_DIR/url_status.log"
CHECKS=25
ALERT_LAST=25
PIPELINE_SCRIPT="$SCRIPT_DIR/pipeline.sh"
FLAG_FILE="$SCRIPT_DIR/pipeline_ran.timestamp"
COOLDOWN=7200

code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 30 "$URL")
if [[ "$code" -eq 200 ]]; then
    echo "1" >> "$STATUS_FILE"
else
    echo "0" >> "$STATUS_FILE"
fi

tail -n $CHECKS "$STATUS_FILE" > "${STATUS_FILE}.tmp" && mv "${STATUS_FILE}.tmp" "$STATUS_FILE"

last_values=$(tail -n $ALERT_LAST "$STATUS_FILE")
sum=$(echo "$last_values" | awk '{s+=$1} END {print s}')
count=$(echo "$last_values" | grep -c '[01]')

now=$(date +%s)
last_run=0
if [[ -f "$FLAG_FILE" ]]; then
    last_run=$(cat "$FLAG_FILE")
fi
diff=$((now - last_run))

if [[ $sum -eq 0 && $count -ge $ALERT_LAST && $diff -ge $COOLDOWN ]]; then
    echo "ALERT: URL $URL is unhealthy. Triggering pipeline..."
    bash "$PIPELINE_SCRIPT"
    echo "$now" > "$FLAG_FILE"
    > "$STATUS_FILE"
fi
