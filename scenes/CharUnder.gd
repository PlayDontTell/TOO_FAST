extends Node2D


var velocity = Vector2.ZERO
var is_char_on_floor: bool
var is_char_on_the_road: bool = true


func _ready():
	$TireSound.play()
	$Engine.play()


func _physics_process(delta):
	$Brake.emitting = is_char_on_floor and Input.get_action_strength("ui_left") > 0 and is_char_on_the_road
	$Brake2.emitting = is_char_on_floor and Input.get_action_strength("ui_left") > 0 and is_char_on_the_road
	
	if Input.get_action_strength("ui_left") > 0 and is_char_on_the_road:
		$TireSound.volume_db = lerp($TireSound.volume_db,
				 -60 + 30 * (Input.get_action_strength("ui_left") + 1), 0.1)
	else:
		$TireSound.volume_db = lerp($TireSound.volume_db, -60, 0.3)
	
	if is_char_on_floor:
		if is_char_on_the_road:
			$Engine.volume_db = lerp($Engine.volume_db, -21, 0.8)
			$Engine.pitch_scale = lerp($Engine.pitch_scale, 1 + 0.1* Input.get_action_strength("ui_right"), 0.3)
		else:
			$Engine.volume_db = lerp($Engine.volume_db, -26 + 4 * abs(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.8)
			$Engine.pitch_scale = lerp($Engine.pitch_scale, 1 + 0.1 * abs(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.3)
	else:
		$Engine.volume_db = lerp($Engine.volume_db, -40, 0.03)
		
