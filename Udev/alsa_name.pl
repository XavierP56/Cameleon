#!/usr/bin/perl
# fixed and persistent naming for multiple (identical or not) usb soundcards, 
# based on which port-hub-usbbus they connect to
#
# gmaruzz (at) celliax.org 
#
# This is to be executed by udev with the following rules:
#KERNEL=="controlC[0-9]*", DRIVERS=="usb", PROGRAM="/usr/bin/alsa_name.pl %k", NAME="snd/%c{1}"
#KERNEL=="hwC[D0-9]*", DRIVERS=="usb", PROGRAM="/usr/bin/alsa_name.pl %k", NAME="snd/%c{1}"
#KERNEL=="midiC[D0-9]*", DRIVERS=="usb", PROGRAM="/usr/bin/alsa_name.pl %k", NAME="snd/%c{1}"
#KERNEL=="pcmC[D0-9cp]*", DRIVERS=="usb", PROGRAM="/usr/bin/alsa_name.pl %k", NAME="snd/%c{1}"
#
use strict;
use warnings;
#
my $alsaname = $ARGV[0]; #udev called us with this argument (%k)
open (MYFILE, '>>/home/xavier/lapin.txt');
print MYFILE $alsaname;
print MYFILE "\n";

my $physdevpath = $ARGV[1];
print MYFILE $physdevpath;
print MYFILE "\n";
my $alsanum = "cucu";

#
if($physdevpath eq "1-8.4") # you can find this value with "dmesg"
{
       $alsanum="25"; #start from "10" (easier for debugging), "0" is for motherboard soundcard, max is "31"
}
if($physdevpath eq "1-8.3") # you can find this value with "dmesg"
{
       $alsanum="26"; #start from "10" (easier for debugging), "0" is for motherboard soundcard, max is "31"
}
if($physdevpath eq "1-8.2") # you can find this value with "dmesg"
{
       $alsanum="27"; #start from "10" (easier for debugging), "0" is for motherboard soundcard, max is "31"
}
if($physdevpath eq "1-8.1") # you can find this value with "dmesg"
{
       $alsanum="28"; #start from "10" (easier for debugging), "0" is for motherboard soundcard, max is "31"
}
# other bus positions....
#
if($alsanum ne "cucu")
{
       $alsaname=~ s/(.*)C([0-9]+)(.*)/$1C$alsanum$3/;
}
#
print $alsaname;
print MYFILE $alsaname;
print MYFILE "\n";
close MYFILE;
exit 0;
