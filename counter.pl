use strict;
use warnings;
use WWW::Curl::Easy;
use POSIX ":sys_wait_h";
use Date::Calc qw( Date_to_Time );
use IO::Handle;

my $withJS = 0;
my $file = "outFile.txt";
my $http200 = 0;
my $http302 = 0;
my $httpOther = 0;
my @ary200 = ();
my @ary302 = ();
my @aryOther = ();
my @aryDatetimes = ();
open my $info, $file or die "Problems opening the recently created $file: $1";
while( my $line = <$info>)  {   
	if ($line =~ /Memento.*([0-9]{14})/) {
		#print "$1";    
		if($withJS == 1){
			#print " without JavaScript\n";
			$withJS = 0;
		}else {
			#print " with JavaScript\n";
			#print $http200." 200s and ".$http302." 302s, ".$httpOther." otherwise\n";
			push(@ary200,$http200);
			push(@ary302,$http302);
			push(@aryOther,$httpOther);
			push(@aryDatetimes,$1);
			$http200 = 0; $http302 = 0; $httpOther = 0;
			$withJS = 1;
		}
		   
	}elsif ($line =~ m/([0-9]{3}).*nasa.gov.*/g){
		if($1 == "200"){
			$http200++;
		}elsif($1 == "302"){
			$http302++;
		}else {
			$httpOther++;
		}
	}
}

print join(",",@ary200)."\n";
print join(",",@ary302)."\n";
print join(",",@aryOther)."\n";
print join(",",@aryDatetimes)."\n";


