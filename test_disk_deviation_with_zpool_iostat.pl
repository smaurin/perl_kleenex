#!/usr/bin/perl

use strict;

my $k; #key
my @track=`zpool iostat -pHlv 5 2` or die "Give me my zpool iostat!";
my $ts=10; # treeshold trigger between mean and current value

# contruit 2 hash, la premiere avec la valeur moyenne, la seconde avec une mesure
# $dev{'ID'}="capacity alloc [0]; cap free [1]; op r [2]; op w [3]; bandwith r[4]; bw w[5]; total_wait r[6]; tw w[7]; disk_wait r[8]; dw w[9]; syncq_wait r[10]; sw w[11]; asyncq_wait r[12]; aw w[13]; scrub wait[14]; trim wait[15]"
my @desc_dev = ("capacity alloc","capacity free","read operations","write operations","bandwith read","bandwidth write","total_wait read","total_wait write","disk_wait read","disk_wait write","syncq_wait read","syncq_wait write","asyncq_wait read","asyncq_wait write","scrub wait","trim wait");
my %dev = map { s/\s+/;/g; chop; split(/;/,$_,2);} (@track[$#track/2+1..$#track]);
my %dev_m = map { s/\s+/;/g; chop; split(/;/,$_,2);} (@track[0..$#track/2]);

foreach $k (sort(keys(%dev))) {

  my @dev_m=split(/;/,$dev_m{$k});
  my @dev=split(/;/,$dev{$k});

  if (@dev[2]>1) { # read OP
    foreach my $n (6,8,10,12) {
            if (@dev[$n]>($ts*@dev_m[$n])) { print "Check RAID: " . $k . " device is at least " . $ts . " times to slow in " . @desc_dev[$n] . " (" . @dev[$n] . " vs " . @dev_m[$n] . " since boot !\n"} ;
    }
  }
  if (@dev[3]>1) { # Write OP
    foreach my $n (7,9,11,13) {
            if (@dev[$n]>($ts*@dev_m[$n])) { print "Check RAID: " . $k . " device is at least " . $ts . " times to slow in " . @desc_dev[$n] . " (" . @dev[$n] . " vs " . @dev_m[$n] . " since boot !\n"} ;
    }
  }
}

