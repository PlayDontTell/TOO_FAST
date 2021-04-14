extends TextureButton


onready var sprite = $MirrorButtonSprite


func _ready():
	initialize_state()


func initialize_state():
	visible = Global.achieved_level_quantity >= 4
	if Global.is_game_mirrored:
		sprite.frame = 1
	else:
		sprite.frame = 0
