extends Area2D


var car_id: int
var speed: float = 120


func _ready():
	position = Vector2(-150, 138)
	$Smoke.modulate = Color(1, 1, 1, 0.3)
	$Siren.play()


func _process(delta):
	position.x += speed * delta
	
	if position.x > 440:
		queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group(""):
		pass
