now = Bacon.fromPoll 1000, ->
	new Bacon.Next Date.now()

# a simple clock
clockUI = document.getElementById('clock')
now.onValue (now) -> 
	clockUI.innerHTML = (new Date()).toLocaleTimeString();

gong = document.getElementById "gong"
gong.addEventListener "ended", ->
	gong.currentSrc = gong.currentSrc
	gong.load()

counterUI = document.getElementById 'counter'
loopsUI = document.getElementById "loops"
statusUI = document.getElementById "status"

zeroPadInteger = ( num ) ->
	str = "00" + parseInt( num, 10 )
	return str.substring( str.length - 2 )

getSeconds = (timing) ->
	type = timing.substr(-1)
	counter = timing.substr(0, timing.length-1)
	switch type
		when 'm'
			parseFloat(counter) * 60
		when 's'
			parseFloat(counter)

currentCounter = null

$counter = $("#counter")
$loops = $("#loops")
$status = $("#status")
$start_timer = $("#start_timer")
$stop_timer = $("#stop_timer")

$preset_list = $ "#preset_list"

stop_the_timer = $stop_timer.asEventStream('click')
start_the_timer = $start_timer.asEventStream('click')
pause_timer = document.getElementById "pause_timer"

toogleUI = ->
	$counter.toggle()
	$loops.toggle()
	$status.toggle()
	$start_timer.toggle()
	$stop_timer.toggle()

stop_the_timer.onValue ->
	currentCounter.stop()
	toogleUI()

start_the_timer.onValue ->
	loadPreset(document.getElementById("preset_list").value, true)
	toogleUI()

class Counter
	# Handles a single countdown

	constructor: (seconds, @statusSink) ->
		@expected_end = Date.now() + seconds*1000
		# handles end of a timer
		@statusSink.onValue (status) => 
			switch status
				when "finished"
					gong.play()
				when "stopped"
					return Bacon.noMore
		@run()

	runClock: (now) =>
		if now >= @expected_end
			return @end()
		else
			minutes = parseFloat( ( (@expected_end - now) / ( 1000 * 60 ) ) % 60)
			seconds = parseFloat( ( (@expected_end - now) / ( 1000 ) ) % 60)
			counterUI.innerHTML = zeroPadInteger(minutes) + ':' + zeroPadInteger(seconds)

	stop: ->
		@statusSink.push "stopped"
		@expected_end = Date.now()

	pause: ->
		console.log "TODO: counter stopped"
		return true	

	run: ->
		now.onValue @runClock
		@statusSink.push "running"

	end: ->
		@statusSink.push "finished"
		console.log "TODO: counter ended"
		return Bacon.noMore

class CounterSetup

	currentCount: 0

	constructor: (@options) ->
		@status = new Bacon.Bus()
		@loopCounter = options.loops
		@countDowns = (getSeconds(timing) for timing in options.clock)
		
		# handles end of a timer
		@status.onValue (status) => 
			statusUI.innerHTML = status
			switch status
				when"running"
					console.log('started to run')
					break;
				when "finished"
					@next()
				when "stopped"
					console.log('timer stopped')
					break
				when "ended"
					console.log "counter setup finished"
					return Bacon.noMore

		if options.autoStart
			@play()

	play: ->
		@countDown = new Counter(@countDowns[@currentCount++], @status)
		loopsUI.innerHTML = "" + @loopCounter + " loops"

	next: ->
		if @countDowns.length > @currentCount
			@play()
		else if @loopCounter == 1
			@status.push "ended"
		else # either loopCounter > 1 or < 1, restart
			@currentCount = 0
			@loopCounter--
			@play()

	stop: ->
		@status.push "ended"
		@status.end()
		@countDown.stop()

	pause: ->
		@countDown.pause()

gong.addEventListener "canplay", ->
	window.loadClock = (options) ->
		currentCounter = new CounterSetup(options)

window.loadClock = (options) ->
	setUpLoadClock = ->
		loadClock options
		gong.removeEventListener "canplay", setUpLoadClock
	gong.addEventListener "canplay", setUpLoadClock
		


window.stopClock = ->
	currentCounter.stop()

$ ->
	listPresets($preset_list, _.template("<option value='<%= key %>'><%= name %> (<%= clock.join(', ') %>)</option>"))