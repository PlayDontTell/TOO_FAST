extends RigidBody2D


var car_id: int
var pollution_disaster_size: float
var speed: float = 10
const TOTAL_OF_CARS: int = 9


func _ready():
	position = Vector2(431, 138)
	car_id = randi() % TOTAL_OF_CARS + 1
	pollution_disaster_size = randf() * 0.1
	$AnimationPlayer.play("car_" + str(car_id))
	$Smoke.modulate = Color(1, 1, 1, pollution_disaster_size)


func _process(delta):
	position.x -= speed * delta
	
	if position.x < -80:
		queue_free()
