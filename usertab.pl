#!/usr/bin/perl
#dostup squid

my $localconf = "/usr/sch/conf/local.conf";
my $musers = "/usr/sch/conf/usertab";
###############################################################################################
print "usertab script is run...\n";

open (LF,"<",$localconf);
while (<LF>)
{
#print "$_\n";
if ($_!~m/(#)|(^\s*\n)/)
 {
  if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/)
   {
     my $kab = $1;
     my $ip  = $2;
     my $mac = $3;
     my $acces = $4; 
     push(@ips,"$kab $ip $mac $acces");
    # print "$kab $ip $mac  $acces\n";
   }
 }
}
close(LF);

open (DF,">",$musers);
foreach $item(@ips)
{
    #     kab     ip      mac     acces
if($item=~(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/))
    {
     my $kab = $1;
     my $ip  = $2;
     my $mac = $3;
     my $acces = $4; 
     print DF "$kab $ip\n";
    }
}
close(DF);
