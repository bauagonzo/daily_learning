# perldoc perlrun
# perldoc perlvar

#
# -p : while (<>) {... ; print $_}
# -n : while (<>) {...}
# -l : chomp; ... ; print "\n";
#
perl -ple '$_=(split /\t/)[1]' lol.txt


#
# -i inplace
# -i.bck inplace + backup *.bck
#
perl -pi -e 's@VNX_BLOCK_BINARY_TEXT@/opt/Navisphere/bin/naviseccli@g;' Collecting/Text-Collector/vnctest/conf/*
