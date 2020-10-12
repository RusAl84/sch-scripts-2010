#!/bin/sh

cd /usr/local/etc/rc.d
sh isc-dhcpd stop
sh isc-dhcpd start
