extends Area2D


onready var level = get_node("../..")

var id: int
var tall_version: bool = false
var short_version: bool = true
var frame_offset: int = 0
var speed: float = 10


func _ready():
	scale.x = Global.mirror_factor
	if Global.is_game_mirrored:
		position = Vector2(-47, 89)
	else:
		position = Vector2(431, 89)
	if tall_version and short_version:
		frame_offset = 27
		$MediumVersion.disabled = true
		$Tallversion.disabled = true
	elif tall_version:
		frame_offset = 9
		$ShortVersion.disabled = true
		$MediumVersion.disabled = true
		$Tallversion2.disabled = true
	elif short_version:
		frame_offset = 18
		$MediumVersion.disabled = true
		$Tallversion.disabled = true
		$Tallversion2.disabled = true
	else:
		frame_offset = 0
		$Tallversion.disabled = true
		$ShortVersion.disabled = true
		$Tallversion2.disabled = true


func _process(delta):
	position.x -= speed * delta
	if not Global.is_game_mirrored:
		$Sprite.frame = 8 - int(abs(position.x) / 384 * 8) + frame_offset
	elif int(abs(position.x) / 384 * 8) + frame_offset < 36:
		$Sprite.frame = int(abs(position.x) / 384 * 8) + frame_offset
	if position.x < -80 and not Global.is_game_mirrored:
		queue_free()
	if position.x > 464 and Global.is_game_mirrored:
		queue_free()


func _on_PanelBack_area_entered(area):
	if area.is_in_group("char_hitbox"):
		print("boom!")
		level.set_char_stuck_in_panel(id)
