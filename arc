#!/bin/sh

#Get current date
TODAY=$(date +%d_%m_%Y)

cd /usr/sch/
mkdir tmp
mkdir arc
cd tmp
mkdir arc$TODAY
cd /usr/sch/tmp/arc$TODAY
mkdir etc
cp -R /etc/ /usr/sch/tmp/arc$TODAY/etc
mkdir usr
cd usr
mkdir sch
cd sch
mkdir conf
mkdir script
#mkdir sites
mkdir db
cp -R /usr/sch/conf/ /usr/sch/tmp/arc$TODAY/usr/sch/conf
cp -R /usr/sch/script/ /usr/sch/tmp/arc$TODAY/usr/sch/script
cp -R /usr/sch/db/ /usr/sch/tmp/arc$TODAY/usr/sch/db
#cp -R /usr/sch/sites/ /usr/sch/tmp/arc$TODAY/usr/sch/sites
cd /usr/sch/tmp/arc$TODAY/usr
mkdir local
cd local
mkdir etc
cp -R /usr/local/etc/ /usr/sch/tmp/arc$TODAY/usr/local/etc
tar cvf - //usr/sch/tmp/arc$TODAY|gzip -9c>/usr/sch/arc/arc_$TODAY.tar.gz
rm -R /usr/sch/tmp/arc$TODAY

exit 0
