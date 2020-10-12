#!/bin/sh
 
#Get current date
TODAY=$(date +%d/%m/%Y)
 
#Get one day ago today
YESTERDAY=$(date -v-1d +%d/%m/%Y)

/usr/local/bin/sarg -o /usr/sch/sites/logs/daily -d $YESTERDAY-$TODAY
 
exit 0
