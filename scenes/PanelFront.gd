extends Area2D


onready var level = get_node("../..")

var id: int
var tall_version: bool = false
var short_version: bool = true
var frame_offset: int = 0
var speed: float = 10


func _ready():
	position = Vector2(431, 89)
	if tall_version and short_version:
		frame_offset = 27
	elif tall_version:
		frame_offset = 9
	elif short_version:
		frame_offset = 18
	else:
		frame_offset = 0
	$Explosion.playing = false
	$Explosion.frame = 0


func _process(delta):
	position.x -= speed * delta
	$Sprite.frame = 8 - int(abs(position.x) / 384 * 8) + frame_offset
	if position.x < -80:
		queue_free()


func explode():
	$Explosion.frame = 1
	$Explosion.playing = true
	$ExplosionSound.play()
