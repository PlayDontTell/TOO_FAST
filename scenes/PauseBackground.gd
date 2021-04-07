extends Sprite


func set_pause_on():
	get_node("../PauseButton").pressed = true
	visible = true
	get_node("../PauseButton").visible = false
	Global.toggle_pause_on()


func set_pause_off():
	Global.toggle_pause_off()
	visible = false
	get_node("../PauseButton").visible = true
	get_node("../PauseButton").pressed = false


func _unhandled_input(event):
	if event is InputEventKey and Global.player_in_game:
		if (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ESCAPE) 
			or Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S) 
			and not event.echo):
			if not get_node("../PauseButton").pressed:
				set_pause_on()
			else:
				set_pause_off()
