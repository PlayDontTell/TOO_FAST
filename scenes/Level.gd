extends Node2D

onready var new_car = "res://scenes/SlowCars.tscn"

var Char_length_in_meters: float = 4.22
var Char_length_in_pixels: float = 63
var meters_per_pixel: float
var length_played_in_meters: float = 0
var length_played_in_kilometers: float = 0
var global_speed: float = 300
var global_slow_speed: float = 50
var time: float = 0

var current_level: int = 0
var levels: Array = [
# length in kilometers ; other cars period ; slow speed ; normal speed
[2, 3, 50, 300],
]


func _ready():
	meters_per_pixel = Char_length_in_meters / Char_length_in_pixels
	spawn_car()
	set_level_parameter()


func set_level_parameter():
	global_speed = levels[current_level][3]
	global_slow_speed = levels[current_level][2]

	$RoadBlock.speed_x = -global_speed
	$Side.speed_x = -global_speed
	$Char.slow_speed = global_slow_speed


func _process(delta):
	time += delta
	length_played_in_meters = time * global_speed * meters_per_pixel + $Char.position.x * meters_per_pixel
	length_played_in_kilometers = stepify(length_played_in_meters / 1000, 0.01)
	
	$CharUnder.position = $Char.position
	$CharUnder.velocity = $Char.velocity
	$CharUnder.is_char_on_floor = $Char.is_on_floor()
	$CharUnder.is_char_on_the_road = not $Char.position.y < 132
	
	if $HUD/Progress.rect_size.x < 372:
		$HUD/Progress.rect_size.x = length_played_in_meters / 1000 / levels[current_level][0] * 372
	$HUD/Distance.position.x = $Char.position.x + 8
	
	if $HUD/Progress.rect_size.x <= 370:
		$HUD/Distance/Figure_1.frame = int(str(length_played_in_kilometers)[0])
		if str(length_played_in_kilometers).length() >= 3:
			$HUD/Distance/Figure_2.frame = int(str(length_played_in_kilometers)[2])
		else:
			$HUD/Distance/Figure_2.frame = 10
		if str(length_played_in_kilometers).length() >= 4:
			$HUD/Distance/Figure_3.frame = int(str(length_played_in_kilometers)[3])
		else:
			$HUD/Distance/Figure_3.frame = 10


func spawn_car():
	var new_car_instance = ResourceLoader.load(new_car)
	new_car_instance = new_car_instance.instance()
	new_car_instance.speed = global_slow_speed
	$OtherCars.add_child(new_car_instance)
	yield(get_tree().create_timer(levels[current_level][1] + randf() * 2), "timeout")
	spawn_car()
