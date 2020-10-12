#!/usr/bin/perl
#mount users direc

my $usersconf = "/usr/sch/conf/users.conf";
###############################################################################################
print "User conf script is run...\n";

open (LF,"<",$usersconf);
while (<LF>)
{
#print "$_\n";
if ($_!~m/(#)|(^\s*\n)/)
 {
  if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+/)
   {
     my $login = $1;
     my $name  = $2;
     my $pass = $3;
     my $access = $4; 
     my $share = $5;
     push(@users,"$login $name $pass $access $share");
#     print "$login $name $pass $access $share\n";
   }
 }
}
close(LF);

foreach $item(@users)
{
if($item=~(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/))
    {
     my $login = $1;
     my $name  = $2;
     my $pass = $3;
     my $access = $4; 
     my $share = $5;
    if (not ($access=~m/none/))
     {
      system"umount /usr/sch/sites/local/home/$access";
     }
    if ($share=~m/share/)
     {
      system"umount /usr/sch/sites/local/home/$login/share";
     }
   }
}
