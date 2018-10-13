extends KinematicBody2D

export(float) var acceleration = 2048
export(float) var deceleration = 2048
export(float) var walk_speed = 512

var velocity = Vector2(0, 0)

func _physics_process(delta):
	var direction = Vector2()
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	
	if direction.x != 0:
		velocity.x += direction.x * delta * acceleration
	else:
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - delta * deceleration)
		elif velocity.x < 0:
			velocity.x = min(0, velocity.x + delta * deceleration)
	velocity.x = clamp(velocity.x, -walk_speed, walk_speed)
	if is_on_wall():
		velocity.x = 0
	if velocity.x != 0:
		move_and_slide(Vector2(velocity.x, 0), Vector2(-1, 0))
	
	var mouse_position = get_viewport().get_mouse_position()
	var angle = (mouse_position - $ray_cast.global_position).angle()
	$ray_cast.rotation = angle
	$ray_cast.force_raycast_update()
	var bomb_point = null
	if $ray_cast.is_colliding():
		bomb_point = $ray_cast.get_collision_point()
	
	if bomb_point:
		var points = PoolVector2Array()
		points.append(Vector2(0, 0))
		points.append(Vector2((bomb_point - $ray_cast.global_position).length(), 0))
		$ray_cast/bomb_line.points = points
		$ray_cast/bomb_line.self_modulate = Color(1, 1, 1, 0.5)
	else:
		$ray_cast/bomb_line.self_modulate = Color(1, 1, 1, 0.1)
	
	if Input.is_action_just_pressed("place_bomb"):
		if bomb_point:
			pass # TODO place bomb
		else:
			pass # TODO play sound effect