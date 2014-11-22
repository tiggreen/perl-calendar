#!/bin/bash
# Kevin Bradley Tigran Hakobyan
# Project 2 addevent.sh

# Usage message
if [ "$#" -ne 4 ]; then
   echo "Usage: addevent.sh accesstoken calendarid eventtext outputfile" >&2
   exit 1
fi

accesstoken=$1
calendarid=$2
eventtext=$3
outputfile=$4
url="https://www.googleapis.com/calendar/v3/calendars/$calendarid/events/quickAdd?text=$eventtext"
cmd="wget --header='Authorization: Bearer $accesstoken' --method='POST' --body-data='' $url -O $outputfile -q"
eval $cmd