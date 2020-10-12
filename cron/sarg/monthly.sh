#!/bin/sh
 
#Get current date
TODAY=$(date +%d/%m/%Y)

#Get one month ago today
YESTERDAY=$(date -v-1m +%d/%m/%Y)

cd /usr/sch/sites/logs
rm -R daily
mkdir daily
rm -R weekly
mkdir weekly
rm -R monthly
mkdir monthly

/usr/local/bin/sarg -o /usr/sch/sites/logs/monthly -d $YESTERDAY-$TODAY
 
exit 0
