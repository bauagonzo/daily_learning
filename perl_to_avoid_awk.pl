#!/usr/bin/perl
open HOSTS,'./seed-emc.txt';
while (my $line=<HOSTS>) {
  my $host=(split(/,/,$line))[0];
  system("snmpwalk -Os -c public -v 2c $host system 2>&1 /dev/null");
  if ($?) {
    print "$host failed\n";
  } else {
    print "$host success\n";
  }
}

