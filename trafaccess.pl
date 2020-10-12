#!/usr/bin/perl
#Generator otchetov trafika - slejenie

my $done = 0;
my $naptime       = 5;
my @users;
my $startipfw= 20000;
my $fc="/usr/sch/conf/firewall.conf";
use DBI;
my $dsn = 'DBI:mysql:traf:localhost';
my $db_user_name = 'traf';
my $db_password = 'MagicTraf';
my $dbh = DBI->connect($dsn, $db_user_name, $db_password) or die "Can't connect to $data_source: $DBI::errstr";
my $pidf       = "/usr/sch/pid/trafaccess";
sub isrun { return -e $pidf; }
sub run { open (RF,">",$pidf); close (RF);}
###############################################################################################
sub onexit
{
unlink($pidf);
$done=1;
}
###############################################################################################
sub init
{
#Razmetit num
$dbh->begin_work;
@users='';
$dbh->do("UPDATE confip SET num = 0");
my $sth = $dbh->prepare(qq{SELECT * FROM confip });
$sth->execute();
my $num = $startipfw;
while (my ($id) = $sth->fetchrow_array())  # делать выборку данных, пока ничего не останется
{
 $dbh->do("UPDATE confip SET num = $num where id=$id");
 push(@users,"$num");
 $num=$num+2;
}
$sth->finish();

#update @users from confip
foreach $item(@users)
{
 $num = $item*1;
 $sth=$dbh->prepare("SELECT num, ip, access, gr_id FROM confip WHERE num=$num");
 $sth->execute();
 my ($num, $ip, $access, $gr_id) = $sth->fetchrow_array();
 $sth->finish();
 $item="$num $ip $access $gr_id";
# print "$item \n";
}
$dbh->commit;

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

#update ipfw from @users
foreach $item(@users)
{
# print "$item\n";
 if ($item=~/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
 {
  my  $num=$1, $ip=$2, $access=$3, $gr_id=$4; 
#  print "$num $ip $access $gr_id \n";
 if ($access=~/1/)
  {
   system("ipfw -q add $num allow tcp from $ip to me 8080 via em1");
   $num++;
   system("ipfw -q add $num allow tcp from me to $ip via em1");   
  }
 else
  {
   system("ipfw -q add $num unreach host tcp from $ip to me 8080 via em1");
   $num++;
   system("ipfw -q add $num unreach host tcp from me 8080 to $ip  via em1");   
  }
 }
}

}
###############################################################################################
sub changeaccess
{ $num=$_[0]; $ip=$_[1]; $access=$_[2];
  # print "$num $ip $access\n";
   system("ipfw -q delete $num");
   $num++;
   system("ipfw -q delete $num");   
   $num--;
 if (($access==1) || ($access=~/(1)/))
  {
   system("ipfw -q add $num allow tcp from $ip to me 8080 via em1");
   $num++;
   system("ipfw -q add $num allow tcp from me to $ip via em1");   
  }
 else
  {
   system("ipfw -q add $num unreach host tcp from $ip to me 8080 via em1");
   $num++;
   system("ipfw -q add $num unreach host tcp from me 8080 to $ip  via em1");   
  }
}
###############################################################################################
sub reloadaccess
{
my $sth = $dbh->prepare(qq{SELECT id,clim FROM lim });
$sth->execute();
while (my ($gr_id, $lim) = $sth->fetchrow_array())  # делать выборку данных, пока ничего не останется
{

 my $ssth=$sth;
 $sth=$dbh->prepare("SELECT sum(used) gused FROM confip WHERE gr_id=$gr_id");
 $sth->execute();
 my ($gused) = $sth->fetchrow_array();
 $sth->finish();
 $lim=$lim*1024*1024;
# print "$gused >= $lim $gr_id\n";
 my $gaccess='1';
 if (($gused >= $lim) && ($lim!~'-1'))
 { 
  $gaccess='0';
 }
 foreach $item(@users)
 {
 # print "$item\n";
  if ($item=~/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  {
   my  $unum=$1, $uip=$2, $uaccess=$3, $ugr_id=$4; 
   my  $cnum, $cip, $caccess, $cgr_id;
   if ($ugr_id==$gr_id)
   {
   #Esli zakrit dotup gruppe
   if ($gaccess==0)
   {
    $caccess=0; $cnum=$unum; $cip=$uip;
   }
   else #Inzche uchitivaem dostup pol`zovatelya
   { 
    $sth=$dbh->prepare("SELECT num, ip, access, gr_id FROM confip WHERE num=$unum");
    $sth->execute();
    ($cnum, $cip, $caccess, $cgr_id) = $sth->fetchrow_array();
    $sth->finish();
   }
   #print "$uaccess !~/$caccess/ $cnum, $cip, $gr_id\n";
   if (($uaccess !~/$caccess/))
    {
     #print "User access is changed - $uaccess - $caccess\n"; 
     changeaccess($cnum, $cip, $caccess); 
     $item="$cnum $cip $caccess $gr_id";
    }
 #  print "$cnum $cip $caccess $gr_id \n";
   }
  }
 }
 $sth=$ssth; 
}
$sth->finish();
}
###############################################################################################

$SIG{INT} ='onexit';
$SIG{KILL}='onexit';
$SIG{TERM}='onexit';

if (!isrun())
{

run;

print "Traffic counter access script is work...\n";
init();
do {
 reloadaccess(); 
 if (!isrun()) { $done=1; }
 sleep $naptime;
} until($done==1);
close(LOGFILE);
$dbh->disconnect();
unlink($pidf);

print "Traffic counter accees script is correctly stop";
}

