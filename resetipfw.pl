#!/usr/bin/perl
#Generator otchetov trafika - slejenie

my $fc="/usr/sch/conf/firewall.conf";

# update ipfw from conf file
system("ipfw -q flush");
open (F, "<", $fc);
while (<F>)
{
#print "$_\n";
if ($_!~m/(#)|(^\s*\n)/)
 {
 my $cmd="ipfw -q ".$_;
 #print "$cmd\n";
 system($cmd);
 }
}
close(F);

