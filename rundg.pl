#!/usr/bin/perl
#Zapusk dansguardian pri zagruzke.

my $naptime       = 5;
my $pidf       = "/usr/sch/pid/dg";
sub isrun { return -e $pidf; }
sub run { open (RF,">",$pidf); close (RF);}
###############################################################################################
sub onexit
{
unlink($pidf);
}
###############################################################################################
if (!isrun())
{

run;
system("dansguardian");

}

