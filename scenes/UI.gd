extends Node2D


onready var game_manager = get_node("../../..")
onready var levels = get_node("../..")


func _ready():
	
	if Global.player_in_game:
		$GlobalMenus.position = Vector2(400, 0)
		levels.current_level = Global.last_level_played
		yield(get_tree(), "idle_frame")
		levels.start_level()
	$GlobalMenus/Menu/Quit.visible = Global.is_quit_button_displayed
	reset_menu()
	$GlobalMenus/Menu.visible = true
	if not Global.game_just_started:
		Global.game_just_started = true
		$Tween.interpolate_property($GlobalMenus, "modulate", Color(0, 0, 0, 1), Color(1, 1, 1, 1), 0.5)
		$Tween.start()



# warning-ignore:unused_argument
func _process(delta):
	$Cursor.position = get_global_mouse_position()


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		$Cursor.play("pressed")
		$Cursor/CursorSound.play()
	else:
		$Cursor.play("default")


func _on_Credits_pressed():
	reset_menu()
	$GlobalMenus/Menu.visible = true


func _on_Play_pressed():
	reset_menu()
	$GlobalMenus/Levels.visible = true
	for i in $GlobalMenus/Levels/Squares.get_children():
		i.initialize_state()


func _on_Options_pressed():
	reset_menu()


func _on_Quit_pressed():
	get_tree().quit()


func _on_CreditsLink_pressed():
	reset_menu()
	$GlobalMenus/Credits.visible = true


func _on_HowToLink_pressed():
	reset_menu()
	$GlobalMenus/HowToPlay.visible = true


func reset_menu():
	$GlobalMenus/Credits.visible = false
	$GlobalMenus/HowToPlay.visible = false
	$GlobalMenus/Menu.visible = false
	$GlobalMenus/Levels.visible = false


func _on_LevelsBack_pressed():
	if $GlobalMenus.position.x == 0:
		reset_menu()
		$GlobalMenus/Menu.visible = true


func launch_level(id):
	if $GlobalMenus.position.x == 0:
		levels.get_node("LevelStartSound").play()
		Global.player_in_game = true
		slide_menu_away()
		Global.last_level_played = id
		levels.current_level = id
		levels.start_level()


func slide_menu_away():
	game_manager.play_level_music()
	$Tween.interpolate_property($GlobalMenus, "position", Vector2(0, 0), Vector2(400, 0), 1.4, Tween.TRANS_CUBIC)
	$Tween.start()


func slide_menu_in():
	game_manager.play_menu_music()
	$Tween.interpolate_property($GlobalMenus, "position", Vector2(400, 0), Vector2(0, 0), 1.4, Tween.TRANS_CUBIC)
	$Tween.start()


# warning-ignore:unused_argument
func _on_MirrorButton_toggled(button_pressed):
	if Global.is_game_mirrored:
		$GlobalMenus/Levels/Squares/MirrorButton/MirrorButtonSprite.frame = 0
		Global.is_game_mirrored = false
		for i in $GlobalMenus/Levels/Squares.get_children():
			i.initialize_state()
			if i.has_node("Set/font"):
				i.get_node("Set/font").flip_h = false
	else:
		$GlobalMenus/Levels/Squares/MirrorButton/MirrorButtonSprite.frame = 1
		Global.is_game_mirrored = true
		for i in $GlobalMenus/Levels/Squares.get_children():
			i.initialize_state()
			if i.has_node("Set/font"):
				i.get_node("Set/font").flip_h = true



