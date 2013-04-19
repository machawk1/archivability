var page = require('webpage').create();
var args = require('system').args;
var fs = require('fs');
var system = require("system");

// the last argument on a command line makes the parameter have a CRLF. Chop this off.
var uri = args[1].replace("%0D%0A","").replace("\r\n","");

//the API is referencing the live web. Fetch from regular ol' wayback
uri = uri.replace("api.wayback.archive.org/memento","web.archive.org/web"); 


var outlogfilename = args[2];

var javascriptflag = args[3].replace("%0D%0A","").replace("\r\n","");
var javascriptfilestring = "_withjs";
if(javascriptflag == "1"){
	page.settings.javascriptEnabled = 	true;
}
else if(javascriptflag == "0"){
	page.settings.javascriptEnabled = 	false;
	javascriptfilestring = "_withoutjs";
}

var sanitizedFilename = uri.replace(/\/|\.|:|\=|\&|\"|\?/g,""); //convert URI to appropriate local filename
var imgfilename = sanitizedFilename+javascriptfilestring+".png";	// You want ping? I got ping!
var logfilename = sanitizedFilename+javascriptfilestring+".log"; // You want log? Wait minute. Ok. I got log!
var htmlfilename = sanitizedFilename+javascriptfilestring+".html"; // Markup? Will have check with boss. Come next week.

console.log(uri);

var logFile = null;

try{
	logFile = fs.open("products/"+outlogfilename,"a","a"); //simple filename in subfolder
	logFile.writeLine("\nMemento: "+uri); 
	logFile.close();
}catch(err){
	console.log("Error on file creation, initial write");
	console.log(err);
}




page.onConsoleMessage = function (msg){
    console.log(msg);     
};   
page.open(uri, function () {	
	//hit the Wayback close button
	page.evaluate(function () { //if javascript is disabled, evaluate is never called
		if(document.getElementById('wm-ipp')){
			document.getElementById('wm-ipp').style.display='none';
		}
	});
	
	logFile = fs.open("products/"+htmlfilename,"a","a"); //simple filename in subfolder
	logFile.writeLine(page.content); 
	logFile.close();
	
	page.viewportSize = { width: 800, height: 600 };
    page.render("products/"+imgfilename); //capture screenshot of the page to a file
    phantom.exit();
});

page.onResourceRequested = function (request) {};

page.onResourceReceived = function (response) {
	// Log the URI and HTTP response when each resource is (or isn't) received
    var logFile2;

    try{
		logFile2 = fs.open("products/"+outlogfilename,"a");
		logFile2.writeLine(response.status+" "+response.url);
		logFile2.close();
	}catch(err) {
		console.log("Error writing response status");
		console.log(err);
	}
};

