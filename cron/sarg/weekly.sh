#!/bin/sh
 
#Get current date
TODAY=$(date +%d/%m/%Y)
 
#Get one week ago today
YESTERDAY=$(date -v-1w +%d/%m/%Y)

/usr/local/bin/sarg -o /usr/sch/sites/logs/weekly -d $YESTERDAY-$TODAY
 
exit 0
