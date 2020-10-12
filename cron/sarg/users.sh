#!/bin/sh

cd /usr/sch/sites/logs
rm -R users
mkdir users

/usr/local/bin/sarg -o /usr/sch/sites/logs/users
 
exit 0
