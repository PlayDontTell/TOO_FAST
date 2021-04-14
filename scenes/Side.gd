extends Sprite


onready var road_block = "res://scenes/Side.tscn"
onready var level = get_node("../..")
onready var group = get_node("..")

var speed_x: float = 0
var is_next_road_block_spawned: bool = false


func _ready():
	speed_x = - level.global_speed
	


func _process(delta):
	if Global.player_in_game:
		position.x += delta * speed_x * Global.mirror_factor
		
		if Global.is_game_mirrored:
			if position.x >= 224 and not is_next_road_block_spawned:
				is_next_road_block_spawned = true
				
				var next_road_block = ResourceLoader.load(road_block)
				next_road_block = next_road_block.instance()
				next_road_block.speed_x = speed_x
				next_road_block.frame = level.current_level
				next_road_block.position = Vector2(position.x + 478 * Global.mirror_factor, position.y)
				
				group.add_child(next_road_block)
			
			if position.x > 644:
				queue_free()
		else:
			if position.x <= 160 and not is_next_road_block_spawned:
				is_next_road_block_spawned = true
				
				var next_road_block = ResourceLoader.load(road_block)
				next_road_block = next_road_block.instance()
				next_road_block.speed_x = speed_x
				next_road_block.frame = level.current_level
				next_road_block.position = Vector2(position.x + 478, position.y)
				
				group.add_child(next_road_block)
			
			if position.x < -260:
				queue_free()
