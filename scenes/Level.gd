extends Node2D

onready var game_manager = get_node("..")
onready var new_car = "res://scenes/SlowCars.tscn"
onready var new_panel_back = "res://scenes/PanelBack.tscn"
onready var new_panel_front = "res://scenes/PanelFront.tscn"
onready var new_police = "res://scenes/Police.tscn"

var Char_length_in_meters: float = 4.22
var Char_length_in_pixels: float = 63
var meters_per_pixel: float
var length_played_in_meters: float = 0
var length_played_in_kilometers: float = 0
var global_speed: float = 300
var global_slow_speed: float = 50
var time: float = 0
var try_numero: int = 0

const TOTAL_OF_CARS: int = 12
var cars_order: Array = []
var last_id_car_used: int = 0
var number_of_cars: int = 0

var panel_id: int = 0
const MAX_COMBO: int = 6
var combo: float = 0
var combo_id_list: Array = []

var level_playing: bool = false
var play_id: int = 0

var current_level: int = 0
var level_length: float = 0
var level_global_speed: float = 1
var level_slow_speed: float = 2

var level_car_spawn_period: int = 3
var level_car_spawn_period_random_factor: int = 4

var level_panel_spawn_period: int = 5
var level_panel_spawn_period_random_factor: int = 6
var level_panel_list: int = 7 # 0 to 4

var level_police_spawn_period: int = 8
var level_police_spawn_period_random_factor: int = 9

var levels: Array = [
#0		#1		#2	#3		#4	#5	#6	#7	#8	#9
[0.3,	160,	50,	2,	1,	3,	2,	4,	10,	2],
]


func _ready():
	meters_per_pixel = Char_length_in_meters / Char_length_in_pixels
	set_level_parameter()
	Global.set_fx_volume(-60)


func start_level():
	if not Global.fx_muted:
		$Tween.interpolate_method(Global, "set_fx_volume", -60, 0, 1)
		$Tween.start()
	play_id += 1
	level_playing = true
	set_level_parameter()
	display_combo()
	spawn_car(play_id)
	spawn_panel(play_id)
	start_police()


func stop_level():
	play_id += 1
	level_playing = false
	for i in $OtherCars.get_children():
		i.queue_free()
	for i in $PanelBacks.get_children():
		i.queue_free()
	for i in $PanelFronts.get_children():
		i.queue_free()
	for i in $PoliceCars.get_children():
		i.queue_free()


func set_level_parameter():
	shuffle_cars_order()
	panel_id = 0
	
	global_speed = levels[current_level][level_global_speed]
	global_slow_speed = levels[current_level][level_slow_speed]

	$RoadBlock.speed_x = -global_speed
	$Side.speed_x = -global_speed
	$Char.slow_speed = global_slow_speed
	$CharUnder/Brake.initial_velocity = global_speed
	$CharUnder/Brake.lifetime = 400 / global_speed
	$CharUnder/Brake2.initial_velocity = global_speed
	$CharUnder/Brake2.lifetime = 400 / global_speed


func _process(delta):
	time += delta
	length_played_in_meters = time * global_speed * meters_per_pixel + $Char.position.x * meters_per_pixel
	length_played_in_kilometers = stepify(length_played_in_meters / 1000, 0.01)
	
	$CharUnder.position = $Char.position
	$CharUnder.velocity = $Char.velocity
	$CharUnder.is_char_on_floor = $Char.is_on_floor()
	$CharUnder.is_char_on_the_road = not $Char.position.y < 132
	
	if $HUD/Progress.rect_size.x < 372:
		$HUD/Progress.rect_size.x = length_played_in_meters / 1000 / levels[current_level][level_length] * 372
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
	
	if not $Char.is_fine:
		$Char.position.x -= delta * global_speed


func reset_combo():
	combo = 0
	combo_id_list.clear()
	display_combo()


func increment_combo(id):
	if not id in combo_id_list and combo < MAX_COMBO:
		combo_id_list.append(id)
		combo += 1
		if combo == MAX_COMBO:
			combo_max()
		display_combo()


func combo_max():
	$ComboSound.play()
	for i in range(10):
		yield(get_tree().create_timer(0.1), "timeout")
		$HUD/Combo.visible = not $HUD/Combo.visible
	yield(get_tree().create_timer(0.8), "timeout")
	reset_combo()


func display_combo():
	$HUD/Combo.visible = combo >= 2
	$HUD/comboParticles_1.visible = combo >= 2
	$HUD/comboParticles_2.visible = combo >= 2
	
	$HUD/comboParticles_1.restart()
	$HUD/comboParticles_2.restart()
	$HUD/comboParticles_1.amount = combo * 5 + 1
	$HUD/comboParticles_1.emitting = true
	$HUD/comboParticles_2.emitting = true
	$HUD/comboParticles_1.hue_variation_random = (combo - 2) / (MAX_COMBO - 2)
	$HUD/comboParticles_2.hue_variation_random = (combo - 2) / (MAX_COMBO - 2)
	$HUD/comboParticles_1.modulate = Color(1, 1, 1 - (combo - 2) / (MAX_COMBO - 2), 1)
	$HUD/comboParticles_2.modulate = Color(1, 1, 1 - (combo - 2) / (MAX_COMBO - 2), 1)
	
	$HUD/Combo.modulate = Color(1, 1 - (combo - 2) / (MAX_COMBO - 2), 1 - (combo - 2) / (MAX_COMBO - 2), 1)
	if str(combo).length() >= 1:
		$HUD/Combo/ComboFigure1.frame = int(str(combo)[0])
	else:
		$HUD/Combo/ComboFigure1.frame = 10
	if str(combo).length() >= 2:
		$HUD/Combo/ComboFigure2.frame = int(str(combo)[1])
	else:
		$HUD/Combo/ComboFigure2.frame = 10
	
	if combo >= 2:
		$HUD/Firework.play()
		$HUD/CoinSound.pitch_scale = 0.5 + (combo - 2) / (MAX_COMBO - 2)
		$HUD/CoinSound.play()


func set_char_stuck_in_panel(event_panel_id):
	$Char.is_fine = false
	$Char.gravity = 0
	$Char/Sprite/AnimationPlayer.play("crash")
	for i in $PanelFronts.get_children():
		if i.id == event_panel_id:
			i.explode()
	
	yield(get_tree().create_timer(1.5), "timeout")
	game_manager.load_scene(game_manager.level)


func shuffle_cars_order():
	last_id_car_used = 0
	cars_order = []
	for i in range(TOTAL_OF_CARS):
		cars_order.append(i + 1)
	cars_order.shuffle()


func spawn_car(play_id_instance):
	if level_playing and play_id_instance == play_id:
		var new_car_instance = ResourceLoader.load(new_car)
		new_car_instance = new_car_instance.instance()
		new_car_instance.speed = global_slow_speed
		new_car_instance.car_id = number_of_cars
		number_of_cars += 1
		new_car_instance.car_type = cars_order[last_id_car_used]
		last_id_car_used += 1
		if last_id_car_used >= TOTAL_OF_CARS:
			shuffle_cars_order()
		$OtherCars.add_child(new_car_instance)
		yield(get_tree().create_timer(levels[current_level][level_car_spawn_period] + randf() * levels[current_level][level_car_spawn_period_random_factor]), "timeout")
		spawn_car(play_id_instance)


func spawn_panel(play_id_instance):
	if level_playing and play_id_instance == play_id:
		var new_panel_back_instance = ResourceLoader.load(new_panel_back)
		new_panel_back_instance = new_panel_back_instance.instance()
		new_panel_back_instance.speed = global_speed
		new_panel_back_instance.id = panel_id
		
		var new_panel_front_instance = ResourceLoader.load(new_panel_front)
		new_panel_front_instance = new_panel_front_instance.instance()
		new_panel_front_instance.speed = global_speed
		new_panel_front_instance.id = panel_id
		
		if not levels[current_level][level_panel_list] == 0:
			var panel_type = randi() % levels[current_level][level_panel_list]
			match panel_type:
				1:
					new_panel_back_instance.short_version = false
					new_panel_front_instance.short_version = false
				2:
					new_panel_back_instance.tall_version = true
					new_panel_front_instance.tall_version = true
					new_panel_back_instance.short_version = false
					new_panel_front_instance.short_version = false
				3:
					new_panel_back_instance.tall_version = true
					new_panel_front_instance.tall_version = true
		$PanelFronts.add_child(new_panel_front_instance)
		$PanelBacks.add_child(new_panel_back_instance)
		
		panel_id += 1
		yield(get_tree().create_timer(levels[current_level][level_panel_spawn_period] + randf() * levels[current_level][level_panel_spawn_period_random_factor]), "timeout")
		spawn_panel(play_id_instance)


func spawn_police(play_id_instance):
	if level_playing and play_id_instance == play_id:
		var new_police_instance = ResourceLoader.load(new_police)
		new_police_instance = new_police_instance.instance()
		$PoliceCars.add_child(new_police_instance)
		yield(get_tree().create_timer(levels[current_level][level_police_spawn_period] + randf() * levels[current_level][level_police_spawn_period_random_factor]), "timeout")
		spawn_police(play_id_instance)


func start_police():
	yield(get_tree().create_timer(levels[current_level][level_police_spawn_period] + randf() * levels[current_level][level_police_spawn_period_random_factor]), "timeout")
	spawn_police(play_id)
