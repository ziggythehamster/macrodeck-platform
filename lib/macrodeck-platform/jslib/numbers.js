// http://sujithcjose.blogspot.com/2007/10/zero-padding-in-java-script-to-add.html
function zeroPad(num,count) {
	var numZeropad = num + '';
	while(numZeropad.length < count) {
		numZeropad = "0" + numZeropad;
	}
	return numZeropad;
}
