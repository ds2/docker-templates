#!/usr/bin/env bash

FAILEDURL=$1

echo "Failed url $FAILEDURL would be reported now!"

[[ -z "${OPSGEN_APIKEY}" ]] && exit 1
[[ -z "${OPSGEN_TEAM_NAME}" ]] && exit 2
[[ -z "${FAILEDURL}" ]] && exit 3

# if [ -z "$OPSGEN_APIKEY" ]; then
#     echo "APIKey not defined!"
#     exit 1
# fi

shaValue=$(echo -n "$FAILEDURL" | sha256sum | awk '{print $1}')

OPSGEN_ALERT_URL=${OPSGEN_ALERT_URL:-https://api.eu.opsgenie.com/v2/alerts}
OPSGEN_PRIO=${OPSGEN_PRIO:-P3}

cat <<EOF >/tmp/alerts.json
{
    "message": "URL Check failed: $FAILEDURL",
    "alias": "${shaValue}",
    "description": "The following url failed to answer within time:\n\n${FAILEDURL}\n\nPlease check ;)",
    "responders": [
        {
            "type": "team",
            "name": "$OPSGEN_TEAM_NAME"
        }
    ],
    "tags": ["urlcheck", "test"],
    "priority": "$OPSGEN_PRIO",
    "details": {
        "url": "$FAILEDURL",
        "reporter": "urlcheck",
        "user": "$(id)"
    }
}
EOF

curl -XPOST -H "Content-Type: application/json" -H "Authorization: GenieKey $OPSGEN_APIKEY" -d @/tmp/alerts.json $OPSGEN_ALERT_URL
