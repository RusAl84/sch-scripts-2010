#!/bin/sh
 
#Get current date
TODAY=$(date +_%d_%m_%Y)

mv /usr/sch/log/access.log /usr/sch/log/access$TODAY.log
gzip -c --best /usr/sch/log/access$TODAY.log > /usr/sch/log/access$TODAY.gz
rm /usr/sch/log/access$TODAY.log

squid -k rotate
squid -k reconfigure

#perl /usr/sch/script/resettrafreload.pl

exit 0
