#!/usr/bin/perl
#Generator otchetov trafika - slejenie 

my $accesslog = "/usr/sch/log/access.log"; 
my $done          = 0;
my $groupsize     = 0;
my $allsize       = 0;
my @ips;
my $naptime       = 5;
use DBI;
my $dsn = 'DBI:mysql:traf:localhost';
my $db_user_name = 'traf';
my $db_password = 'MagicTraf';
my $dbh = DBI->connect($dsn, $db_user_name, $db_password) or die "Can't connect to $data_source: $DBI::errstr";
my $pidf       = "/usr/sch/pid/reloadtraf";
sub isrun { return -e $pidf; }
sub run { open (RF,">",$pidf); close (RF);}

###############################################################################################
sub onexit
{
unlink($pidf);
$done=1;
}
###############################################################################################
sub loadips{
$host=$_[0]; $result=$_[1]; $size=$_[2];  $dsthost=$_[3];
 if(!($result=~m/TCP_HIT/) and !($result=~m/TCP_IMS_HIT/) and !($result=~m/TCP_MEM_HIT/))
 {
      my $exist=0;
      foreach $item(@ips)
      {
      #             host    size
      if($item=~(/(\S+)\s+(\S+)/))
        {
         my $fhost=$1;
	 my $fsize=$2;
         # print "$fhost $fsize\n";
	 if($fhost=~m/($host)/)
	 {
          if (isfree())
	  {
          $size=0;
          }
          $fsize+=$size;
	  $item="$fhost $fsize";
          $exist=1;
         }
	}
      }
      
      if (!$exist)
      {
         if (isfree())
	 {
         $size=0;
         }
      push(@ips,"$host $size");  
      }
 }     
}
########################################################################################
sub isfree{
$dsthost=$_[0];
if (($dsthost=~m/sch1254.lan/) or ($dsthost=~m/kaspersky-labs.com/) or ($dsthost=~m/voumdo.ru/) or ($dsthost=~m/192.168.2.2/)){
return 1}
  else 
{return 0}
}
##########################################################################################################################
sub updatedb{
$dbh->begin_work;
      foreach $item(@ips)
      {
      #             host    size
      if($item=~(/(\S+)\s+(\S+)/))
        {
         my $host=$1;
         my $size=$2;
         # print "$host $size\n";
         $dbh->do("UPDATE `confip` SET used = $size WHERE ip = '$host'");
        }
      }
$dbh->commit;
}
###########################################################################################
$SIG{INT} ='onexit';
$SIG{KILL}='onexit';
$SIG{TERM}='onexit';

if (!isrun())
{
run;
print "Traffic couter reload script is work...\n";
#obnulit used
$dbh->begin_work;
$dbh->do("UPDATE `confip` SET used = 0");
$dbh->commit;

open (LOGFILE,"<",$accesslog);
do {
  for ($curpos = tell(LOGFILE); <LOGFILE>; $curpos = tell(LOGFILE))
    {
      if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/)
      {
         my $host    = $3;
         my $result  = $4;
         my $size    = $5;
         my $dsthost = $7;
         loadips($host, $result, $size, $dsthost);
      }
    }
    if (!isrun())
    {
      $done = 1;
    }
    updatedb;
    sleep $naptime;
    seek(LOGFILE, $curpos,0);
} until($done==1);
close(LOGFILE);
$dbh->disconnect();
unlink($pidf);

print "Traffic counter reload script is correctly stop";
}
