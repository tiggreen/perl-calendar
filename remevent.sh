#!/bin/bash
# Kevin Bradley Tigran Hakobyan
# Project 2 remevent.sh

# Usage message
if [ "$#" -ne 3 ]; then
   echo "Usage: remevent.sh accesstoken calendarid eventid" >&2
   exit 1
fi

accesstoken=$1
calendarid=$2
eventid=$3
url="https://www.googleapis.com/calendar/v3/calendars/$calendarid/events/$eventid"
cmd="wget --header='Authorization: Bearer $accesstoken' --method='DELETE' --ignore-length $url -q"
eval $cmd
