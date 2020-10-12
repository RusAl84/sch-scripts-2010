#!/bin/sh

sh /usr/local/etc/rc.d/isc-dhcpd stop
perl /usr/sch/script/dhcpd.pl
perl /usr/sch/script/usertab.pl
sh /usr/local/etc/rc.d/isc-dhcpd start

