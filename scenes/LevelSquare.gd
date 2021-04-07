extends TextureButton


onready var ui = get_node("../../../..")

export var level_id: int = 0


func _ready():
	initialize_state()
	$Set/font.frame = level_id + 1
	$Set/background.frame = level_id
	$Set.modulate = Color(0.4, 0.4, 0.4, 1)


func _on_LevelSquare_pressed():
	ui.launch_level(level_id)


func _on_LevelSquare_mouse_entered():
	$Set.modulate = Color(1, 1, 1, 1)


func _on_LevelSquare_mouse_exited():
	$Set.modulate = Color(0.4, 0.4, 0.4, 1)


func initialize_state():
	visible = Global.achieved_level_quantity >= level_id
