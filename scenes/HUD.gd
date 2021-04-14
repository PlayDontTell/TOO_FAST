extends Node2D


onready var level = get_node("..")


func _ready():
	$UI.visible = true
	$PauseBackground.visible = false


func _on_PauseButton_toggled(button_pressed):
	if button_pressed:
		$PauseBackground.set_pause_on()


func _on_Resume_pressed():
	$PauseBackground.set_pause_off()


func _on_MenuInGame_pressed():
	level.level_playing = false
	Global.player_in_game = false
	Global.set_level_fx_volume(-60)
	$UI.reset_menu()
	$UI/GlobalMenus/Levels.visible = true
	$UI.slide_menu_in()
	
	yield(get_tree().create_timer(1.2), "timeout")
	level.stop_level()
	$PauseBackground.set_pause_off()
