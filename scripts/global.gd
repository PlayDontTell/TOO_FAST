extends Node


# Meta variables
const DEV_MODE: bool = not true
var count_test: int = 0
var language: String = "eng"
var game_just_started: bool = false
var achieved_level_quantity: int = 0 # From 0 to 7
var achieved_mirrored_level_quantity: int = 0 # From 0 to 7
var personal_best: float = 0 # From 0 to 7

# UI variables
var logo_visible: bool = false
var force_hidden_cursor: bool = false
var force_menu_cursor: bool = false
var mouse_hovering_count: int = 0
var fx_muted: bool = false
var music_muted: bool = false
var is_quit_button_displayed: bool = true
var last_level_played: int = 0
var player_in_game: bool = false
var is_game_mirrored: bool = false
var mirror_factor: int = 1

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


func set_level_fx_volume(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Level_Fx"), value)


func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(str(achieved_level_quantity))
	save_game.store_line(str(achieved_mirrored_level_quantity))
	save_game.store_line(str(personal_best))
	save_game.close()


func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	achieved_level_quantity = int(save_game.get_line())
	achieved_mirrored_level_quantity = int(save_game.get_line())
	personal_best = float(save_game.get_line())
	save_game.close()
