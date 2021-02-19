extends Node


# Meta variables
const DEV_MODE: bool = true
var count_test: int = 0
var language: String = "eng"

# UI variables
var logo_visible: bool = false
var force_hidden_cursor: bool = false
var force_menu_cursor: bool = false
var mouse_hovering_count: int = 0
var fx_muted: bool = false
var music_muted: bool = false

# Colors
const COLOR_DEFAULT = Color(1, 1, 1, 1)
const COLOR_HIGHLIGHT = Color(4, 4, 4, 1)
const COLOR_TRANPARENT = Color(1, 1, 1, 0)
const COLOR_SHADED = Color(0.7, 0.7, 0.7, 1)
const COLOR_BLACK = Color(0, 0, 0, 1)
const COLOR_WHITE = Color(4, 4, 4, 1)


func _ready():
	OS.window_fullscreen =  not DEV_MODE
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func print_test():
	print(count_test)
	count_test += 1


func toggle_pause_on():
	if not get_tree().paused:
		get_tree().paused = true
		Physics2DServer.set_active(true)
		print("__GAME_PAUSED__")


func toggle_pause_off():
	if get_tree().paused:
		get_tree().paused = false
		print("__GAME_RESUMED__")


func disable_input(duration):
	# Disable all input and hide the cursor for <duration> seconds.
	get_tree().get_root().set_disable_input(true)
	force_hidden_cursor = true
	yield(get_tree().create_timer(duration), "timeout")
	get_tree().get_root().set_disable_input(false)
	force_hidden_cursor = false


func set_fx_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Fx"), value)


func set_music_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)
