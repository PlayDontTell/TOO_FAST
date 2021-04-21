extends Area2D


var car_id: int
var speed: float = 120


func _ready():
	scale.x = Global.mirror_factor
	if Global.is_game_mirrored:
		position = Vector2(534, 138)
	else:
		position = Vector2(-150, 138)
	$Smoke.modulate = Color(1, 1, 1, 0.3)
	$Siren.play()


func _process(delta):
	position.x += speed * delta
	
	if position.x > 440 and not Global.is_game_mirrored:
		queue_free()
	if position.x < -56 and Global.is_game_mirrored:
		queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group(""):
		pass
