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
var shield: bool = false

var mirrored_offset_x: int = 0

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
var level_restarting: bool = false

var current_level: int = 0

var level_length: float = 0
var level_global_speed: float = 1
var level_slow_speed: float = 2

var level_car_spawn_period: int = 3
var level_car_spawn_period_random_factor: int = 4

var level_panel_spawn_period: int = 5
var level_panel_spawn_period_random_factor: int = 6
var level_panel_list: int = 7 # 0 to 3

var level_police_spawn_period: int = 8
var level_police_spawn_period_random_factor: int = 9
var level_police_double_patrol: int = 10
var level_police_speed: int = 11

var levels: Array = [
#0		#1		#2		#3		#4		#5		#6		#7		#8		#9		#10			#11

[0.2,	130,	45,		2.5,	0.5,	4.20,	0.75,	1,		0,		0, 		false,		0],

[0.5,	190,	55,		1.8,	0.9,	3.5,	1.25,	2,		17,		0.5, 	false,		110],

[0.8,	250,	65,		1.1,	1.3,	2.8,	1.75,	3,		14,		0.9, 	true,		125],

[1.2,	310,	75,		0.4,	1.7,	2.1,	2.25,	4,		11,		1.5, 	true,		140],

[99.0,	310,	75,		0.4,	1.7,	2.1,	2.25,	4,		11,		1.5, 	true,		140],
]


func _ready():
	$HUD.visible = true
	$HUD/RetryBase.visible = false
	$HUD/Combo.visible = false
	meters_per_pixel = Char_length_in_meters / Char_length_in_pixels
	set_level_parameter()
	Global.set_level_fx_volume(-60)


func start_level():
	level_restarting = false
	Global.toggle_pause_off()
	
	$HUD/RetryBase.visible = false
	
	$Char.is_fine = true
	$Char.gravity = 700
	$Char/Sprite/AnimationPlayer.play("default")
	$Char.position = Vector2(1000, -100)
	$Char.rotation_degrees = 0
	$Char.z_index = 0
	$Char.was_hit_by_police = false
	$Char.enable_collisions()
	
	set_shield_disabled()
	
	$HUD/Progress.rect_size.x = 0
	Global.player_in_game = true
	time = 0
	length_played_in_meters = 0
	panel_id = 0
	set_level_parameter()
		
	reset_combo()
	$HUD/ComboMAX.visible = false
	Global.set_level_fx_volume(0)
	play_id += 1
	level_playing = true
	
	$SlowCarTimer.wait_time = levels[current_level][level_car_spawn_period] + randf() * levels[current_level][level_car_spawn_period_random_factor]
	$SlowCarTimer.start()
	$PanelTimer.wait_time = levels[current_level][level_panel_spawn_period] + randf() * levels[current_level][level_panel_spawn_period_random_factor]
	$PanelTimer.start()
	start_police()
	set_mirrored_level(Global.is_game_mirrored)


func set_mirrored_level(is_game_mirrored):
	Global.mirror_factor = -1 if is_game_mirrored else 1
	$Char.scale.x = Global.mirror_factor
	$CharUnder.scale.x = Global.mirror_factor
	levels[current_level][level_global_speed] *= Global.mirror_factor
	levels[current_level][level_slow_speed] *= Global.mirror_factor
	levels[current_level][level_police_speed] *= Global.mirror_factor
	$HUD/Background.scale.x = Global.mirror_factor
	if is_game_mirrored:
		mirrored_offset_x = 384
		$Char.position = Vector2(299, 137)
		$HUD/Progress.rect_position.x = 383
		$HUD/Background.position.x = 384
	else:
		mirrored_offset_x = 0
		$Char.position = Vector2(85, 137)
		$HUD/Progress.rect_position.x = 1
		$HUD/Background.position.x = 0


func finish_level():
	$VictorySound.play(0.0)
	Global.toggle_pause_on()
	play_id += 1
	level_playing = false
	Global.player_in_game = false
	if Global.is_game_mirrored:
		if Global.achieved_mirrored_level_quantity <= current_level:
			Global.achieved_mirrored_level_quantity = current_level + 1
	else:
		if Global.achieved_level_quantity <= current_level:
			Global.achieved_level_quantity = current_level + 1
	Global.save_game()
	Global.set_level_fx_volume(-60)
	$HUD/UI.reset_menu()
	$HUD/UI/GlobalMenus/Levels.visible = true
	for i in $HUD/UI/GlobalMenus/Levels/Squares.get_children():
		i.initialize_state()
	$HUD/UI.slide_menu_in()
	yield(get_tree().create_timer(1.0), "timeout")
	Global.toggle_pause_off()
	time = 0
	stop_level()
	reset_combo()


func stop_level():
	set_shield_disabled()
	$PanelTimer.stop()
	$PoliceTimer.stop()
	$SlowCarTimer.stop()
	$PanelTimer.wait_time = 1
	$PoliceTimer.wait_time = 1
	$SlowCarTimer.wait_time = 1
	play_id += 1
	level_playing = false
	Global.player_in_game = false
	for i in $OtherCars.get_children():
		i.queue_free()
	for i in $PanelBacks.get_children():
		i.queue_free()
	for i in $PanelFronts.get_children():
		i.queue_free()
	for i in $PoliceCars.get_children():
		i.queue_free()


func set_level_parameter():
	for i in $RoadBlocks.get_children():
		i.position.x = 205
		i.speed_x = -levels[current_level][level_global_speed * Global.mirror_factor]
		i.frame = current_level
	for i in $Sides.get_children():
		i.position.x = 205
		i.speed_x = -levels[current_level][level_global_speed * Global.mirror_factor]
		i.frame = current_level
	
	$Background.frame = current_level

	shuffle_cars_order()
	panel_id = 0
	
	global_speed = levels[current_level][level_global_speed]
	global_slow_speed = levels[current_level][level_slow_speed]
	
	$Char.slow_speed = global_slow_speed
	$CharUnder/Brake.initial_velocity = global_speed
	$CharUnder/Brake.lifetime = abs(400 / global_speed)
	$CharUnder/Brake2.initial_velocity = global_speed
	$CharUnder/Brake2.lifetime = abs(400 / global_speed)


func _process(delta):
	if Global.player_in_game and not level_restarting:
		time += delta
	length_played_in_meters = time * global_speed * meters_per_pixel + ($Char.position.x - 100) * meters_per_pixel * Global.mirror_factor
	length_played_in_kilometers = stepify(length_played_in_meters / 1000, 0.01)
	
	$CharUnder.position = $Char.position
	$CharUnder.velocity = $Char.velocity
	$CharUnder.is_char_on_floor = $Char.is_on_floor()
	$CharUnder.is_char_on_the_road = not $Char.position.y < 132
	
	$HUD/Distance.position.x = $Char.position.x + 8
	
	if $HUD/Progress.rect_size.x <= 369:
		$HUD/Distance/Figure_1.frame = int(str(length_played_in_kilometers)[0])
		if str(length_played_in_kilometers).length() >= 3:
			$HUD/Distance/Figure_2.frame = int(str(length_played_in_kilometers)[2])
		else:
			$HUD/Distance/Figure_2.frame = 10
		if str(length_played_in_kilometers).length() >= 4:
			$HUD/Distance/Figure_3.frame = int(str(length_played_in_kilometers)[3])
		else:
			$HUD/Distance/Figure_3.frame = 10
	
	if $HUD/Progress.rect_size.x < 371:
		$HUD/Progress.rect_size.x = int(length_played_in_meters / 1000 / levels[current_level][level_length] * 371)
		if Global.is_game_mirrored:
			$HUD/Progress.rect_position.x = 383 - $HUD/Progress.rect_size.x
		$HUD/Progress.modulate = Color(length_played_in_meters / 1000 / levels[current_level][level_length], 1, 0, 1)
	elif level_playing and $Char.is_fine and not $Char.was_hit_by_police:
		finish_level()
	
	if not $Char.is_fine:
		$Char.position.x -= delta * global_speed * Global.mirror_factor


func set_shield_enabled():
	shield = true
	$Char/Glow.visible = true
	$Char/GlowParticles.visible = true
	$HUD/UI/Vignette.modulate = Color(1, 1, 1, 5)
	$HUD/shieldLABEL.visible = true


func set_shield_disabled():
	shield = false
	$Char/Glow.visible = false
	$Char/GlowParticles.visible = false
	$HUD/UI/Vignette.modulate = Color(1, 1, 1, 0.25)
	$HUD/shieldLABEL.visible = false
	$Char/ShieldActiveSound.stop()


func enable_shield():
	$Char/ShieldOn.play()
	$Char/ShieldActiveSound.play()
	set_shield_enabled()


func disable_shield():
	$Char/ShieldOff.play()
	set_shield_disabled()


func reset_combo():
	$HUD/ComboMAX.visible = false
	combo_id_list.clear()
	combo = 0
	display_combo()


func increment_combo(id):
	if not id in combo_id_list and combo < MAX_COMBO and $Char.position.y < 132 and not shield and $Char.is_fine:
		combo_id_list.append(id)
		combo += 1
		if combo == MAX_COMBO:
			combo_max()
		display_combo()


func combo_max():
	enable_shield()
	reset_combo()
	$ComboSound.play()
	$HUD/Combo/ComboFigure1.visible = false
	$HUD/Combo/ComboFigure2.visible = false
	$HUD/ComboMAX.modulate = $HUD/Combo.modulate
# warning-ignore:unused_variable
	for i in range(6):
		yield(get_tree().create_timer(0.1), "timeout")
		$HUD/Combo.visible = not $HUD/Combo.visible
		$HUD/ComboMAX.visible = $HUD/Combo.visible
		$HUD/shieldLABEL.visible = $HUD/Combo.visible
	$HUD/shieldLABEL.visible = true
	yield(get_tree().create_timer(0.8), "timeout")


func display_combo():
	$HUD/Combo.visible = combo >= 2
	$HUD/comboParticles_1.visible = combo >= 2
	$HUD/comboParticles_2.visible = combo >= 2
	$HUD/Combo/ComboFigure1.visible = combo >= 2 and not combo == MAX_COMBO
	$HUD/Combo/ComboFigure2.visible = combo >= 2 and not combo == MAX_COMBO
	
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
	if shield:
		disable_shield()
	else:
		$Char.is_fine = false
		$Char.gravity = 0
		$Char/Sprite/AnimationPlayer.play("crash")
		for i in $PanelFronts.get_children():
			if i.id == event_panel_id:
				i.explode()
		setup_restart()


func shuffle_cars_order():
	last_id_car_used = 0
	cars_order = []
	for i in range(TOTAL_OF_CARS):
		cars_order.append(i + 1)
	cars_order.shuffle()


func _on_SlowCarTimer_timeout():
	spawn_car(play_id)
	$SlowCarTimer.wait_time = levels[current_level][level_car_spawn_period] + randf() * levels[current_level][level_car_spawn_period_random_factor]
	$SlowCarTimer.start()


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


func _on_PanelTimer_timeout():
	spawn_panel(play_id)
	$PanelTimer.wait_time = levels[current_level][level_panel_spawn_period] + randf() * levels[current_level][level_panel_spawn_period_random_factor]
	$PanelTimer.start()


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
			if panel_id == 0:
				panel_type = levels[current_level][level_panel_list] - 1
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


func spawn_police(play_id_instance):
	if level_playing and play_id_instance == play_id and not levels[current_level][level_police_spawn_period] == 0:
		var new_police_instance = ResourceLoader.load(new_police)
		new_police_instance = new_police_instance.instance()
		new_police_instance.speed = levels[current_level][level_police_speed] * Global.mirror_factor
		$PoliceCars.add_child(new_police_instance)
		
		if levels[current_level][level_police_double_patrol]:
			yield(get_tree().create_timer(1.3), "timeout")
			var new_police_instance_2 = ResourceLoader.load(new_police)
			new_police_instance_2 = new_police_instance_2.instance()
			new_police_instance_2.speed = levels[current_level][level_police_speed] * Global.mirror_factor
			$PoliceCars.add_child(new_police_instance_2)


func start_police():
	if not levels[current_level][level_police_spawn_period] == 0:
		$PoliceTimer.wait_time = levels[current_level][level_police_spawn_period] + randf() * levels[current_level][level_police_spawn_period_random_factor]
		$PoliceTimer.start()


func _on_PoliceTimer_timeout():
	spawn_police(play_id)
	if not levels[current_level][level_police_spawn_period] == 0:
		$PoliceTimer.wait_time = levels[current_level][level_police_spawn_period] + randf() * levels[current_level][level_police_spawn_period_random_factor]
		$PoliceTimer.start()


func setup_restart():
	$HUD/Combo.visible = false
	$HUD/ComboMAX.visible = false
	$HUD/Combo.visible = false
	$RestartTimer.start()
	level_restarting = true
	
	$HUD/RetryBase/Distance2/Figure_1.frame = int(str(levels[current_level][level_length])[0])
	if str(levels[current_level][level_length]).length() >= 3:
		$HUD/RetryBase/Distance2/Figure_2.frame = int(str(levels[current_level][level_length])[2])
	else:
		$HUD/RetryBase/Distance2/Figure_2.frame = 0
	if str(levels[current_level][level_length]).length() >= 4:
		$HUD/RetryBase/Distance2/Figure_3.frame = int(str(levels[current_level][level_length])[3])
	else:
		$HUD/RetryBase/Distance2/Figure_3.frame = 0
	
	
	$HUD/RetryBase/Distance3/Figure_1.frame = int(str(length_played_in_kilometers)[0])
	if str(length_played_in_kilometers).length() >= 3:
		$HUD/RetryBase/Distance3/Figure_2.frame = int(str(length_played_in_kilometers)[2])
	else:
		$HUD/RetryBase/Distance3/Figure_2.frame = 0
	if str(length_played_in_kilometers).length() >= 4:
		$HUD/RetryBase/Distance3/Figure_3.frame = int(str(length_played_in_kilometers)[3])
	else:
		$HUD/RetryBase/Distance3/Figure_3.frame = 0
	
	$HUD/RetryBase.visible = true


func _on_RestartTimer_timeout():
	if not get_tree().paused and not $HUD/UI/GlobalMenus.position.x < 400:
		game_manager.load_scene(game_manager.level)
