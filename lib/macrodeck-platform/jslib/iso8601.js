/* http://dansnetwork.com/2008/11/01/javascript-iso8601rfc3339-date-parser/ */
Date_setISO8601 = function(theDate, dString){
	var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;
	if (dString.toString().match(new RegExp(regexp))) {
		var d = dString.match(new RegExp(regexp));
		var offset = 0;
		theDate.setUTCDate(1);
		theDate.setUTCFullYear(parseInt(d[1],10));
		theDate.setUTCMonth(parseInt(d[3],10) - 1);
		theDate.setUTCDate(parseInt(d[5],10));
		theDate.setUTCHours(parseInt(d[7],10));
		theDate.setUTCMinutes(parseInt(d[9],10));
		theDate.setUTCSeconds(parseInt(d[11],10));
		if (d[12])
			theDate.setUTCMilliseconds(parseFloat(d[12]) * 1000);
		else
			theDate.setUTCMilliseconds(0);
		if (d[13] != 'Z') {
			offset = (d[15] * 60) + parseInt(d[17],10);
			offset *= ((d[14] == '-') ? -1 : 1);
			theDate.setTime(theDate.getTime() - offset * 60 * 1000);
		}
	} else {
		theDate.setTime(Date.parse(dString));
	}
	return theDate;
};

/* https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date#Example.3a_ISO_8601_formatted_dates */
Date_getISO8601 = function(theDate){
	function pad(n){return n<10 ? '0'+n : n}
	return theDate.getUTCFullYear()+'-'
		+ pad(theDate.getUTCMonth()+1)+'-'
		+ pad(theDate.getUTCDate())+'T'
		+ pad(theDate.getUTCHours())+':'
		+ pad(theDate.getUTCMinutes())+':'
		+ pad(theDate.getUTCSeconds())+'Z'
};
