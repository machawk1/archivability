

my $uriBase = "http://api.wayback.archive.org/memento/";
my $uriProxyBase = "http://mementoarchive.lanl.gov/ia/";
#http://mementoarchive.lanl.gov/ta/20100320180023/http://lanlsource.lanl.gov/pics/picoftheday.png

my $url = "http://matkelly.com";
for($y=2000; $y<2011; $y++){
	#$fullURL = $uriBase.$y."0101000000/".$url."\n";
	#system("phantomjs fetchDateBasedURI.js \"$fullURL\" $y");
	system("phantomjs fetchDateBasedURI.js \"$url\" $y");
	 
}	

#*/

#http://api.wayback.archive.org/memento/20060514123511/http://www.matkelly.com/

#20060514123511/http://www.matkelly.com/"
#system("phantomjs makeImageFromMemento.js");
