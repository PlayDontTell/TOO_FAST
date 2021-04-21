extends Node2D


var velocity = Vector2.ZERO
var is_char_on_floor: bool
var is_char_on_the_road: bool = true


func _ready():
	$TireSound.play()
	$Engine.play()


# warning-ignore:unused_argument
func _physics_process(delta):
	if Global.is_game_mirrored:
		$Brake.emitting = is_char_on_floor and Input.get_action_strength("ui_right") > 0 and is_char_on_the_road
		$Brake2.emitting = is_char_on_floor and Input.get_action_strength("ui_right") > 0 and is_char_on_the_road
	else:
		$Brake.emitting = is_char_on_floor and Input.get_action_strength("ui_left") > 0 and is_char_on_the_road
		$Brake2.emitting = is_char_on_floor and Input.get_action_strength("ui_left") > 0 and is_char_on_the_road
	
	if Input.get_action_strength("ui_left") > 0 and is_char_on_the_road:
		$TireSound.volume_db = lerp($TireSound.volume_db,
				 -60 + 30 * (Input.get_action_strength("ui_left") + 1), 0.15)
	else:
		$TireSound.volume_db = lerp($TireSound.volume_db, -60, 0.3)
	
	if is_char_on_floor:
		if is_char_on_the_road: # On the road.
			$Engine.volume_db = lerp($Engine.volume_db, -24, 0.1)
			$Engine.pitch_scale = lerp($Engine.pitch_scale, 1.05 + 0.05 * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.3)
		else: # On other cars.
			$Engine.volume_db = lerp($Engine.volume_db, -24 + 4 * abs(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.1)
			$Engine.pitch_scale = lerp($Engine.pitch_scale, 1 + 0.05 * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.3)
	else: # In the air
		$Engine.volume_db = lerp($Engine.volume_db, -28, 0.1)
		$Engine.pitch_scale = lerp($Engine.pitch_scale, 0.95 + 0.05 * (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), 0.3)
	
	
