#!/bin/bash
# Kevin Bradley (kmb3398)
# Project 2 listevents.sh

# Usage message
if [ "$#" -ne 3 ]; then
   echo "Usage: listevents.sh accesstoken calendarid outputfile" >&2
   exit 1
fi

accesstoken=$1
calendarid=$2
outputfile=$3
url="https://www.googleapis.com/calendar/v3/calendars/$calendarid/events"
cmd="wget --header='Authorization: Bearer $accesstoken' --method='GET' $url -O $outputfile -q"
eval $cmd
