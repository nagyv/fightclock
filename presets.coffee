s4 = ->
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1);
guid = ->
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
         s4() + '-' + s4() + s4() + s4();

lset = (key, data) ->
	return localStorage.setItem key, JSON.stringify(data)

lget = (key) ->
	return JSON.parse(localStorage.getItem(key))

$presets = $ "#presets"
$preset_container = $ ".preset"
$presetFields = $ "#presetFields"
$presetForm = $ "#presetForm"
$presetForm.submit (ev) ->
	ev.preventDefault()

add_preset_click = $("#add_preset").asEventStream("click")
add_next_track_click = $("#add_next_track").asEventStream("click")
save_preset_click = $("#save_preset").asEventStream("click")

keys = lget("Presets" ) || []

add_next_track_click.onValue (ev) ->
	$(ev.target).before $preset_container.clone()

add_preset_click.onValue ->
	$presetForm.show()

getValue = (wrapper) ->
	return "" + wrapper.querySelector('.number').value + wrapper.querySelector('.unit').value

save_preset_click.onValue (ev) ->
	key = guid()
	data = {
		name: document.getElementById( "preset_name").value,
		clock: (getValue wrapper for wrapper in $presetFields.find('.preset')),
		loops: document.getElementById( "preset_loops").value
	}
	lset key, data
	keys.push key
	lset "Presets", keys
	init()
	presetForm.reset()
	$presetForm.hide()

deletePreset = (key) ->
	localStorage.removeItem key
	keys = lget("Presets" ) || []
	init()

window.loadPreset = (key, autoStart) ->
	data = lget key
	data.autoStart = autoStart
	loadClock(data)

window.listPresets = (container, template) ->
	container.html("")

	listPreset = (key) ->
		data = lget(key)
		if data
			data.key = key
			container.append template(data)

	(listPreset(key) for key in keys)

init = ->
	listPresets($presets, _.template("<li data-key='<%= key %>{key}'><%= name %> (<%= clock.join(', ') %>) <button data-key='<%= key %>'>x</button></li>"))
	$presets.find('button').click ->
		deletePreset this.dataset.key
		$(this).parent().remove()

do ->
	init()
	