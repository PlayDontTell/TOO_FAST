extends TextureButton


func _ready():
	initialize_state()


func initialize_state():
	visible = Global.achieved_level_quantity >= 4
