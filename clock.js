/*global $,document,setTimeout,alert */
var container = $('container');
var loopCounter = document.getElementById('loops');
var clock = document.getElementById('clock');
var counter = document.getElementById('counter');

function zeroPadInteger( num ) {
	var str = "00" + parseInt( num, 10 );
	return str.substring( str.length - 2 );
}

function getSeconds(timing) {
	var type = timing.substr(-1);
	var counter = timing.substr(0, timing.length-1);
	switch(type) {
		case 'm':
			return parseFloat(counter) * 60;
		case 's':
			return parseFloat(counter);
	}
}

function clockStopped(idx) {
	alert('the clock stopped');
	startClock(++idx);
}

function runClock(ends, idx) {
	var now = Date.now();
	if(Date.now() >= ends) {
		clockStopped(idx);
	} else {
		var minutes = parseInt( ( ends - now / ( 1000 * 60 ) ) % 60, 10 );
		var seconds = parseInt( ( ends - now / ( 1000 ) ) % 60, 10 );
		clock.innerHTML = now.toLocaleTimeString();
		counter.innerHTML = zeroPadInteger(minutes) + ':' + zeroPadInteger(seconds);
		setTimeout(function(){
			runClock(ends, idx);
		}, 1000);
	}
}

function startClock(idx) {
	var expected_end;
	try {
		expected_end = Date.now() + parseFloat(container.children()[idx].attr("data-time"))*1000;
	} catch(e) {
		// no such idx
		return false;
	}
	runClock(expected_end, idx);
}

function loadClock(options) {
	options.clock.forEach(function(timing) {
		container.append('<li data-time="' + getSeconds(timing) + '">' + timing + '</li>');
	});
	loopCounter.value = options.loops;
	if(options.autoStart) {
	 startClock(0);
	}
}

