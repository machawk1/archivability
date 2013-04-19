/* *************************
scrapeAlexaTop500.js
This code is meant to be used by phantomjs, the headless WebKit, to scrape Alexa's
 top 500 sites list, which is paginated, and output the contents to stdout. This output
 can be directed to a file with '> {filename}'. It was created as a means to get the
 most popular sites but is really a one-off whose task could probably have been done
 manually in the time it took to code it.

20130124 MAT  initial implementation
*************************** */

var page = require('webpage').create(); //include necessary phantomjs module

openPage(0);

function openPage(i){
	if(i > 500/25){phantom.exit();}//top 500 / 25 per page
	var uri = "http://www.alexa.com/topsites/global;"+i; //alexa URIs use this scheme plus a number for each page
	
	//I use a recursive timeout function because phantomjs had issues accessing multiple URis via a loop
	page.open(uri, function (status) {	
		//console.log("Opening page "+uri);
		// Output data style: site1name||site2name||site3name|||site1uri||site2uri||site3uri
		var compositeDataString = page.evaluate(function(){
			var strurls = "";
			var strsitenames = "";
			for(var ii=0; ii<25; ii++){
				strurls += ((document.querySelectorAll('.topsites-label'))[ii]).innerHTML+"||";
				strsitenames += ((document.querySelectorAll('h2 a'))[ii]).innerHTML+"||";
			}
			return strsitenames+"|||"+strurls;
		});
		
		var siteComponents = compositeDataString.split("|||"); //split the site names from site URIs
		var siteNames = siteComponents[0].split("||"); //break the || delimited list of names into an array
		var siteURIs = siteComponents[1].split("||"); //break the || delimited list of uris into an array
		for(var ii=0; ii<siteNames.length; ){ //loop through each (consistent length with padding anomaly)
			console.log(siteNames[ii++].trim()+" "+siteURIs[ii]); //oddly, the first element is blank for URIs
		}
	});
	//recursively call parent function with pseudo random delay to prevent bot detection
	window.setTimeout(function(){openPage(++i);},(2000*Math.random()) + 1);
	
}


