extends RigidBody2D


onready var levels = get_node("../..")
onready var char_instance = get_node("../../Char")


var car_id: int
var car_type: int
var pollution_disaster_size: float
var honk_id: String
var speed: float = 10
var was_hit_by_police: bool = false
var is_char_on_roof: bool = false


func _ready():
	position = Vector2(431, 138)
	honk_id = str(randi() % 9 + 1)
	pollution_disaster_size = randf() * 0.1
	$AnimationPlayer.play("car_" + str(car_type))
	$Area2D/CollisionPolygon2D.polygon = $CollisionPolygon2D.polygon
	$Smoke.modulate = Color(1, 1, 1, pollution_disaster_size)


func _physics_process(delta):
	position.x -= speed * delta
	
	if position.x < -80:
		queue_free()


func hit_by_police():
	was_hit_by_police = true
	call_deferred("set_mode", RigidBody2D.MODE_CHARACTER)
	call_deferred("disable_collisions")
	$Destroy.play()
	$AnimatedSprite.play("car_" + str(car_type) + "_crash")
	rotation_degrees = -15
	linear_velocity = Vector2(-200 - randi() % 40, -180 - randi() % 40)
	if is_char_on_roof:
		char_instance.velocity = Vector2(-150, -270)
	yield(get_tree().create_timer(0.4), "timeout")
	z_index = -1


func set_mode(new_mode):
	mode = new_mode


func disable_collisions():
	$CollisionPolygon2D.disabled = true


func _on_Area2D_area_entered(area):
	if area.is_in_group("char_collision_under"):
		if not was_hit_by_police:
			get_node("Honks/honk_" + honk_id).play()
			is_char_on_roof = true
			levels.increment_combo(car_id)
	elif area.is_in_group("char_collision_sides"):
		if not was_hit_by_police:
			$Hit.play()
	elif area.is_in_group("police"):
		if not was_hit_by_police:
			hit_by_police()


func _on_Area2D_area_exited(area):
	if area.is_in_group("char_collision_under"):
		is_char_on_roof = false
