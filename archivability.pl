#!/usr/bin/env perl

#######################################################
# archivability.pl
# The eventual purpose of this program will be to utilize phantomJS to get screenshot 
#  and HTTP responses for resources that make up a web page and from that, extrapolate
#  the degree at which a page was archivable at various points in time.
#
# Contact Mat Kelly <me@matkelly.com> for more questions/info
#
#  Version
#  20130129 - MAT - Added flag to allow JS support to be specific at runtime
#  20130127 - MAT - Added support to Alexa Top 500 input file
#  20130125 - MAT - Init
#######################################################

use strict;
use warnings;
use WWW::Curl::Easy;
use POSIX ":sys_wait_h";
use Date::Calc qw( Date_to_Time );
use IO::Handle;

# Handle the parameters passed in to ensure                                       
####################################################################

print "Number of args: ".($#ARGV+1)."\n";


my @sites = ();
if($#ARGV + 1 == 0){
	print "Using the top 500 list as a data source\r\n";
	# Read the top 500 URI text file, output the URI
	####################################################################
	open my $top500file, "top500.txt" or die "Problems opening top 500 file";
	#for (my $siteI=0; $siteI<500; $siteI++) {
	while (my $topsite = <$top500file>) {
		#my $topsite = <$top500file>;
		my @arry = split(' ',$topsite);
		push(@sites,"http://".$arry[$#arry]);
		last if $#arry > 10;
	}
}elsif($#ARGV + 1 < 2){
	print "Usage: archivability.pl <url> <filename>\n";
	print "Usage: archiveability.pl\n";
	print "       - uses Alexa top 500 as datasource";
	#print "Usage: archivability.pl <url> <filename> {startyear} {endyear}\n\n";
	print "Example archivability.pl \"http://www.cnn.com\" mementos_out1.txt\n";
	#print "Example archivability.pl \"http://www.odu.edu\" mementos_out2.txt 2001 2008\n";
	exit;
}else {
	push(@sites,$ARGV[0])
}
#else if($#ARGV + 1 == 4){ #years defined for limited range
	
#}



for (my $siteI=0; $siteI<($#sites+1); $siteI++) {   # Venturing beyond the top 10 exponentially heightens the chance that it's pornography
 #begin site for
	# Fetch the mementos of the passed in URI via Internet Archive's API                                       
	####################################################################

	my $curl = WWW::Curl::Easy->new;
	$curl->setopt(CURLOPT_HEADER,1);
	$curl->setopt(CURLOPT_URL, 'http://api.wayback.archive.org/list/timemap/link/'.$sites[$siteI]);
	print 'http://api.wayback.archive.org/list/timemap/link/'.$sites[$siteI]."\n";


	my $response_body;
	$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
	print "Fetching Mementos for ".$sites[$siteI]." from IA's timemap...\n";
	my $retcode = $curl->perform;
	
	
	my @allMementoDates = ($response_body =~ m/\/(\d{14})\//g);
	if ($#allMementoDates == -1) {#There were no mementos for this site, e.g. Facebook.com
		print "There were no mementos for ".$sites[$siteI]."\r\n";
		next;
	}
	#STDOUT->printflush($response_body);



	my $lastPivot = 0; 	#set the first basis to the first element, further premise will be spread from this
											# this might be suboptimal and does not guarantee spread minimalization
	my $pivotI = $lastPivot;

	#for my $mementoDate (@allMementoDates) {
	my $yearInMinutes = 24 * 60 * 60 * 365; # Oh, the naivete!
	my @dateIntervalAry = ($allMementoDates[$lastPivot]);
	
	my $previousDateTested;

	for (my $dateI = 1; $dateI < $#allMementoDates + 1; $dateI++) {
		#print $mementoDate . "\n";

		# Create a perl date object based on a simple YYYYMMDDhhmmss string
		#  This will make comparing easier
		#######################################################
		my @date1Obj = (( substr $allMementoDates[$lastPivot] , 0 , 4 ) , #YYYY
					( substr $allMementoDates[$lastPivot] , 4 , 2 ) ,     #MM
					( substr $allMementoDates[$lastPivot] , 6 , 2 ),     #DD
					( substr $allMementoDates[$lastPivot] , 8 , 2 ),     #hh
					( substr $allMementoDates[$lastPivot] , 10 , 2 ),     #mm
					( substr $allMementoDates[$lastPivot] , 12 , 2 ));     #ss
		my @date2Obj = (( substr $allMementoDates[$dateI] , 0 , 4 ) ,  #YYYY
						( substr $allMementoDates[$dateI] , 4 , 2 ) ,  #MM
						( substr $allMementoDates[$dateI] , 6 , 2 ),  #DD
						( substr $allMementoDates[$dateI] , 8 , 2 ),  #hh
						( substr $allMementoDates[$dateI] , 10 , 2 ),  #mm
						( substr $allMementoDates[$dateI] , 12 , 2 ));  #ss
		my $dateBasis = Date_to_Time(@date1Obj);
		print (substr $allMementoDates[$dateI], 0, 4);
		my $dateTested = Date_to_Time(@date2Obj);

		if( $dateBasis + $yearInMinutes <= $dateTested ){
			print $allMementoDates[$lastPivot]." to ".$allMementoDates[$dateI]." is more than a year";
			
			# find which is closest to lastPivot between value at dateI and dateI-1 (these spread interval mark)
			if(!$previousDateTested || abs($dateTested - $dateBasis + $yearInMinutes) >= abs($previousDateTested - $dateBasis + $yearInMinutes)){ #the previous iteration's date was closer to the pivot + 1 year 
				print " but last iteration was closer\n";
				$lastPivot = $dateI-1;
			}else { #this iteration is closest to the pivot + 1 year
				print " and this iteration is closer\n";
				$lastPivot = $dateI;
			}
			push(@dateIntervalAry,$allMementoDates[$lastPivot]);
			
		}else {
			print $allMementoDates[$lastPivot]." to ".$allMementoDates[$dateI]." is less than a year\n";
			$previousDateTested = $dateTested;	#store for next iteration
		}

	}

	# Make memento URIs from dates
	my @mementoURIs = @dateIntervalAry;
	my $prefixURI = "http://api.wayback.archive.org/memento/";
	
	for(my $dateI=$#dateIntervalAry; $dateI >= 0; $dateI--){
		print 
		$mementoURIs[$dateI] = $prefixURI.$dateIntervalAry[$dateI]."/".$sites[$siteI];
	}



	my $OUTFILE = "mementos.txt";
	if ($retcode == 0) {
		print("> SUCCESS!\n");
		#my @uris = ($response_body=~ m/<(.*[0-9]{14}.*)>/g);
		
		#open (MEMENTOFILE,'>>'.$ARGV[1]);
		open (MEMENTOFILE,'>>'.$OUTFILE);
		print MEMENTOFILE join("\r\n",@mementoURIs); #Write the memento URIs out to a CRLF delimitted file
		close (MEMENTOFILE);
	} else {
		print("> FAILED\n");
		print("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}


	#  Make an image of each memento via phantomjs                    
	#######################################################

	#my $file = $ARGV[1];
	my $file = $OUTFILE;
	open my $info, $file or die "Problems opening the recently created $file: $1";
	my $count = 0;
	my $exited_cleanly;
	while( my $line = <$info>)  {   
		#sleep(1); #Now, now script, be nice!
		print "Site ".$siteI." - Calling phantomJS with $line\n";    
		
		eval{
			local $SIG{ALRM} = sub { die "alarm\n" }; #This is required
			
			alarm 90; # If phantomjs process doesn't return after a sufficient amount of time, kill
			system("phantomjs makeImageFromMemento.js \"$line\" outFile.txt 1"); #js ON
			system("phantomjs makeImageFromMemento.js \"$line\" outFile.txt 0"); #js OFF
			alarm 0;
		};
		++$count;
	   #last if ++$count > 2; #artificial restrcition of two mementos for testing
	}

	close $info;


} #end site for
