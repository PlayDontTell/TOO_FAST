extends Node2D


onready var game_manager = get_node("..")


func _ready():
	$Logo.modulate = Global.COLOR_BLACK
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Global.logo_visible = true
	yield(get_tree().create_timer(0.0),"timeout")
	$LogoSound.play()
	yield(get_tree().create_timer(0.7),"timeout")
	$Tween.interpolate_property($Logo, "modulate", Global.COLOR_BLACK, Global.COLOR_DEFAULT, 1, Tween.TRANS_SINE)
	$Tween.start()
	
	
	yield(get_tree().create_timer(2),"timeout")

	$Tween.interpolate_property($Logo, "modulate", Global.COLOR_DEFAULT, Global.COLOR_BLACK, 0.5, Tween.TRANS_SINE)
	$Tween.start()
	yield(get_tree().create_timer(0.6),"timeout")
	
	Global.logo_visible = false
	game_manager.load_scene(game_manager.level)
