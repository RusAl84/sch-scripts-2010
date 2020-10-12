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
    if ($access=~m/teachers-upload/)
     {
      print "teachers-upload $login $access \n";
      system"mkdir /usr/sch/sites/local/home/$login/teachers-upload";
      system"mount_nullfs /usr/sch/sites/local/home/teachers-upload /usr/sch/sites/local/home/$login/teachers-upload";
     }
    if ($access=~m/arhiv/)
     {
      print "archive $login $access \n";
      system"mkdir /usr/sch/sites/local/home/$login/arhiv";
      system"mount_nullfs /usr/sch/sites/local/pub/Архив /usr/sch/sites/local/home/$login/arhiv ";
     }
    if ($share=~m/share/)
     {
#      print "share $login $share \n";
      system"mkdir /usr/sch/sites/local/home/$login/share";
      system"mkdir /usr/sch/sites/local/pub/Учителя/$name";
      system"mount_nullfs /usr/sch/sites/local/home/$login/share /usr/sch/sites/local/pub/Учителя/$name";
      system"mkdir /usr/sch/sites/www/teachers/$name";
      system"mount_nullfs /usr/sch/sites/local/home/$login/share /usr/sch/sites/www/teachers/$name";

     }
   }
}

#arhiv vo vneshku
 system"mkdir /usr/sch/sites/www/arhiv";
 system"mount_nullfs /usr/sch/sites/local/pub/Архив /usr/sch/sites/www/arhiv";
#uchitelya vo vneshku
 system"mkdir /usr/sch/sites/www/teachers";

