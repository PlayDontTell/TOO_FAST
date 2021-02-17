extends KinematicBody2D

export (int) var speed = 280
export (int) var jump_speed = -280
export (int) var gravity = 700

var velocity = Vector2.ZERO
var slow_speed: float = 50

export (float, 0, 1.0) var friction = 0.02
export (float, 0, 1.0) var acceleration = 0.04

func get_input():
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	elif position.y >= 132:
		velocity.x = lerp(velocity.x, 0, friction)

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed
			$Jump.play()
	
	if (is_on_floor() and not position.y < 132) or (is_on_floor() and position.y < 132 
		and Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") != 0):
		$Sprite/AnimationPlayer.playback_speed = 1
	else:
		$Sprite/AnimationPlayer.playback_speed = 0
	
	if position.y < 132:
		$Sprite/AnimationPlayer.play("default_in_the_air")
		if is_on_floor() and Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") == 0:
			velocity.x = lerp(velocity.x, -slow_speed, 0.2)
	else:
		$Sprite/AnimationPlayer.play("default")
	
	$Smoke.initial_velocity = 80 -  20 * abs(velocity.x / 300)
