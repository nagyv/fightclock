/*global $,document,setTimeout,console,Bacon */
var now = Bacon.fromPoll(1000, function(){
	return new Bacon.Next(Date.now());
});
var running = new Bacon.Bus();

var container = $('#container');
var loopCounter = document.getElementById('loops');
var clockUI = document.getElementById('clock');
var counterUI = document.getElementById('counter');

now.onValue(function(now) {
	clockUI.innerHTML = (new Date()).toLocaleTimeString();
});
running.onValue(function(running) {
	if(running) {
		console.log('started to run');
	} else {
		console.log('timer stopped');
	}
});

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

function runClock(ends, now) {
	if(now >= ends) {
		running.push(false);
		return Bacon.noMore;
	} else {
		var minutes = parseFloat( ( (ends - now) / ( 1000 * 60 ) ) % 60);
		var seconds = parseFloat( ( (ends - now) / ( 1000 ) ) % 60);
		counterUI.innerHTML = zeroPadInteger(minutes) + ':' + zeroPadInteger(seconds);
	}
}

function startClock(idx) {
	var expected_end;
	try {
		expected_end = Date.now() + parseFloat(container.children()[idx].dataset.time)*1000;
	} catch(e) {
		// no such idx
		return false;
	}
	running.push(true);
	now.onValue(runClock, expected_end);
	if(loopCounter.value === 0) {
		
	}
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
