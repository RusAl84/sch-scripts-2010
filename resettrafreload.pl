#!/usr/bin/perl
#reset

my $pidf="/usr/sch/pid/reloadtraf";
sub resettraf { unlink($pidf);}

resettraf;


