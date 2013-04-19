var page = require('webpage').create();
var args = require('system').args;
var fs = require('fs');
var system = require("system");
var uri = args[1];
var uriProxyBase = "http://mementoarchive.lanl.gov/ia/";
var uriIAAPI = "http://api.wayback.archive.org/list/timemap/link/"

console.log("URI passed in is "+uri);
var date = args[2];
if(!date || date.length < 14){console.log("Bad date passed in. Use YYYYMMDDhhmmss"); phantom.exit();}

var ano = date.substr(0,4);
var mes = date.substr(4,2)-1; // "Javascript is dumb" - MLN
var dia = date.substr(6,2);
var hora = date.substr(8,2);
var minuto = date.substr(10,2);
var segundo = date.substr(12,2);

uriIAAPI += uri;
console.log(uriIAAPI);
phantom.exit();


//console.log((new Date(date)).toUTCString()):
//var fullURL = uriProxyBase+new Date(ano,mes,dia,hora,minuto,segundo))+uri;

//phantom.exit();

page.customHeaders = {'Accept-Datetime':(new Date(ano,mes,dia,hora,minuto,segundo))};

page.open(uri, function () {	
	var sanitizedFileName = uri.replace(/\/|\.|\:|\=|\?|\&|\"|\\n|\\r/g,"").trim();
    console.log(sanitizedFileName);
    
    page.render(sanitizedFileName+".png");
	phantom.exit();
/*	my $toSave = $URIR;
	$toSave =~ s/://ig;
	$toSave =~ s/\/\///ig;
	$toSave =~ s/\.//ig;
	$toSave =~ s/\///ig;
	$toSave =~ s/=//ig;
	$toSave =~ s/\?//ig;
	$toSave =~ s/\&//ig;
	$toSave =~ s/\"//ig;

	$toSave = trim($toSave);
*/
});
