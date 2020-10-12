#!/usr/bin/perl
#Generator pravil dlya ipfw - razdelenie po segmentam

my $localconf = "/usr/sch/conf/local.conf";
my $ports     = "0,3,4,8,11,20,21,22,53,67,68,80,137,138,443,49152-65534";
my $sr        = 10000;
my @ips;
my @gac;
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
     my $ip  = $2;
     my $access = $4;
     push(@ips,"$ip $access");
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
     #print "$ip $access \n";
     my @ac=$access =~ /(\w+)/g;
     foreach $item(@ac)
     {
      my $exist=0;
      foreach $sitem(@gac)
      { if ($sitem eq $item) { $exist=1; }  }
      if ($exist==0) { push(@gac,"$item"); }
     }
   }
 }
}
close(LF);

 my $num = $sr;
foreach $ac(@gac)
{
 my @vips = '';
 foreach $ipitem(@ips)
 {
  if ($ipitem =~ /(\S+)\s+(\S+)/)
   {
    my $ip  = $1;
    my $access = $2;
    #print "$ac $ip $access \n";
    my @acm=$access =~ /(\w+)/g;
    my $exist=0;
    foreach $item(@acm)
    {
     if ($ac eq $item) { $exist=1; }
    }       
    if (($exist == 1) and ($ip ne ""))
    {
    push(@vips,"$ip"); 
    # print "found $ac $ip \n";
    } 
  }
 }
 my @pips;
 foreach $csegm(@segm)
 {
 my $first=1;
 my $pip = "";
 foreach $ip(@vips)
 { 
  if ($ip =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/)
  {
  my $ccsegm = $3;
  my $lip = $4;
  if ($ccsegm eq $csegm)
   {
    #print "$ac $ip \n";
    if ($first==1) { $pip="192.168.$csegm.0/24{$lip,";}
    if ($first==0) { $pip="$pip$lip,"; }
    $first=0;
   }     
  }
 }
 if ($first==0) { chop($pip); $pip="$pip}";}
 if ($pip ne '') { push(@pips,"$pip"); }
 }
 
 foreach $pip(@pips)
 {
 
  foreach $topip(@pips)
  {
   if ($pip ne $topip)
   {
    $num = $num + 1; 
    my $s1 = "ipfw -q add $num  allow all from $pip to $topip via xl1";
    $num = $num + 1; 
    my $s2 = "ipfw -q add $num  allow all from $topip to $pip via xl1";
    system($s1);
    system($s2); 
    print "$ac $num $pip $topip\n ";
   }
  }
#  print "$ac $pip\n";
 }
}

#print "$num \n";
