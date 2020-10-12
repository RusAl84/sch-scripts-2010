#!/bin/sh
chown -R squid:squid /usr/sch/db/squidGuard
squidGuard -C /usr/sch/db/squidGuard/my/domains
squidGuard -C /usr/sch/db/squidGuard/my/urls
squidGuard -C /usr/sch/db/squidGuard/exc/domains
squidGuard -C /usr/sch/db/squidGuard/exc/urls
chown -R squid:squid /usr/sch/db/squidGuard
squid -k reconfigure
