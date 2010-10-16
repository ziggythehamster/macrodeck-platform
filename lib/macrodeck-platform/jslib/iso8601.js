/* http://dansnetwork.com/2008/11/01/javascript-iso8601rfc3339-date-parser/ */
Date.prototype.setISO8601 = function(dString){
	var regexp = /(\d\d\d\d)(-)?(\d\d)(-)?(\d\d)(T)?(\d\d)(:)?(\d\d)(:)?(\d\d)(\.\d+)?(Z|([+-])(\d\d)(:)?(\d\d))/;
	if (dString.toString().match(new RegExp(regexp))) {
		var d = dString.match(new RegExp(regexp));
		var offset = 0;
		this.setUTCDate(1);
		this.setUTCFullYear(parseInt(d[1],10));
		this.setUTCMonth(parseInt(d[3],10) - 1);
		this.setUTCDate(parseInt(d[5],10));
		this.setUTCHours(parseInt(d[7],10));
		this.setUTCMinutes(parseInt(d[9],10));
		this.setUTCSeconds(parseInt(d[11],10));
		if (d[12])
			this.setUTCMilliseconds(parseFloat(d[12]) * 1000);
		else
			this.setUTCMilliseconds(0);
		if (d[13] != 'Z') {
			offset = (d[15] * 60) + parseInt(d[17],10);
			offset *= ((d[14] == '-') ? -1 : 1);
			this.setTime(this.getTime() - offset * 60 * 1000);
		}
	} else {
		this.setTime(Date.parse(dString));
	}
	return this;
};

/* https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date#Example.3a_ISO_8601_formatted_dates */
Date.prototype.getISO8601 = function(){
	function pad(n){return n<10 ? '0'+n : n}
	return this.getUTCFullYear()+'-'
		+ pad(this.getUTCMonth()+1)+'-'
		+ pad(this.getUTCDate())+'T'
		+ pad(this.getUTCHours())+':'
		+ pad(this.getUTCMinutes())+':'
		+ pad(this.getUTCSeconds())+'Z'
};

/* http://anentropic.wordpress.com/2009/06/25/javascript-iso8601-parser-and-pretty-dates/ */
function parseISO8601(str) {
	// we assume str is a UTC date ending in 'Z'

	var parts = str.split('T'),
	dateParts = parts[0].split('-'),
	timeParts = parts[1].split('Z'),
	timeSubParts = timeParts[0].split(':'),
	timeSecParts = timeSubParts[2].split('.'),
	timeHours = Number(timeSubParts[0]),
	_date = new Date;

	_date.setUTCFullYear(Number(dateParts[0]));
	_date.setUTCMonth(Number(dateParts[1])-1);
	_date.setUTCDate(Number(dateParts[2]));
	_date.setUTCHours(Number(timeHours));
	_date.setUTCMinutes(Number(timeSubParts[1]));
	_date.setUTCSeconds(Number(timeSecParts[0]));
	if (timeSecParts[1]) _date.setUTCMilliseconds(Number(timeSecParts[1]));

	// by using setUTC methods the date has already been converted to local time(?)
	return _date;
}
