extends TextureButton


export var output: String


func _ready():
	match output:
		"music":
			pressed = Global.music_muted
		"fx":
			pressed = Global.fx_muted


func _on_Cross_pressed():
	match output:
		"music":
			Global.music_muted = pressed
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -60 if pressed else 0)
		"fx":
			Global.fx_muted = pressed
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Fx"), -60 if pressed else 0)
