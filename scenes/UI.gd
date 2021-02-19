extends Node2D


func _process(delta):
	$Cursor.position = get_global_mouse_position()


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		$Cursor.play("pressed")
		get_node("Cursor/Bopsounds/Bop_" + str(randi()% 8 + 1)).play()
	else:
		$Cursor.play("default")


func _on_Credits_pressed():
	$Credits.visible = false
