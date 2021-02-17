extends Sprite


onready var road_block = "res://scenes/Side.tscn"
onready var level = get_node("..")

var speed_x: float = 0
var is_next_road_block_spawned: bool = false


func _ready():
	speed_x = - level.global_speed


func _process(delta):
	
	position.x += delta * speed_x
	
	if position.x <= 160 and not is_next_road_block_spawned:
		is_next_road_block_spawned = true
		
		var next_road_block = ResourceLoader.load(road_block)
		next_road_block = next_road_block.instance()
		next_road_block.speed_x = speed_x
		next_road_block.position = Vector2(position.x + 478, position.y)
		
		get_node("..").add_child(next_road_block)
		get_node("..").move_child(next_road_block, 4)
	
	if position.x < -260:
		queue_free()
