extends Node2D

var lang_screen = "res://levels/LangScreen.tscn"
var logo_screen = "res://scenes/LogoScreen.tscn"
var level = "res://scenes/Level.tscn"


func _ready():
	if Global.DEV_MODE:
		load_scene(level)
	else:
		load_scene(logo_screen)


func load_scene(scene):
	
	if scene == level:
		play_menu_music()
	
	# Load the next room and the ui node.
	var next_scene = ResourceLoader.load(scene)
	
	# Instance the next room and the ui node.
	var current_scene = next_scene.instance()
	
	yield(get_tree(), "idle_frame")
	
	if get_child_count() > 0:
		for i in get_children():
			if not i.name == "Ressources":
				remove_child(i)
				i.queue_free()
	
	add_child(current_scene)


func play_menu_music():
	if $Ressources/Music_2.playing:
		$Ressources/Tween.interpolate_property($Ressources/Music_2, "volume_db",  $Ressources/Music_2.volume_db, -60, 3)
		$Ressources/Tween.start()
	$Ressources/Music_1.play()


func play_level_music():
	if $Ressources/Music_1.playing:
		$Ressources/Tween.interpolate_property($Ressources/Music_1, "volume_db", $Ressources/Music_1.volume_db, -60, 3)
		$Ressources/Tween.start()
	$Ressources/Music_2.play()
