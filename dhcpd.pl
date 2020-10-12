#!/usr/bin/perl
#Generator pravil dlya ipfw - razdelenie po segmentam

my $localconf = "/usr/sch/conf/local.conf";
my $dhcpdconf = "/usr/local/etc/dhcpd.conf";
my $ports     = "20,21,22,53,67,68,80,137,138,443,49152-65534";
my $sr        = 10000;
my @ips;
my @segm;
my $naptime = 5;
###############################################################################################
print "local script is run...\n";

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
     push(@ips,"$kab $ip $mac");
#     print "$kab $ip $mac \n";
     if ($ip =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/)
	{
	my $csegm = $3;
	my $exist = '0';
	foreach $item(@segm)
	 {
	  if ($item == $csegm)
	   {$exist='1'} 	 
	 }
	if ($exist=='0')
	 {push(@segm,"$csegm");}
	#print "--- $csegm\n";
	}
   }
 }
}
close(LF);

open (DF,">",$dhcpdconf);
print DF "default-lease-time 43200;\n";
print DF "max-lease-time 43200;\n";
print DF "ddns-update-style none;\n";
print DF "authoritative;\n";
print DF "log-facility local7;\n\n";
print DF "shared-network Intranet-sch1254\n";
print DF "{\n";
print DF "subnet 192.168.10.0 netmask 255.255.255.0 {\n";
print DF " option domain-name-servers 192.168.10.1;\n";
print DF " option subnet-mask 255.255.0.0;\n"; 
print DF " option routers 192.168.10.1;\n";
print DF " range 192.168.10.100 192.168.10.170;\n";
print DF "}\n\n";

foreach $gsegm(@segm)
 {
  print DF "subnet 192.168.$gsegm.0 netmask 255.255.255.0 {\n";
  print DF " option domain-name-servers 192.168.$gsegm.1;\n";
  print DF " option routers 192.168.$gsegm.1;\n";
  print DF " option subnet-mask 255.255.0.0;\n"; 
  foreach $item(@ips)
  {
  #            kab     ip      mac
  if($item=~(/(\S+)\s+(\S+)\s+(\S+)/))
    {
     my $kab = $1;
     my $ip  = $2;
     my $mac = $3;
     if ($ip =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/)
      {
	my $csegm = $3;
	if ($gsegm == $csegm) 
	{
	 if ($mac =~ /(\w{2})\:(\w{2})\:(\w{2})\:(\w{2})\:(\w{2})\:(\w{2})/ ) 
	 { print DF " host $kab { hardware ethernet $mac; fixed-address $ip; }\n"; }
	}
      }
#     print "$kab $ip $mac \n";
    }
  }
  print DF "}\n";
 }
print DF "}\n";
close(DF);

