extends KinematicBody2D

export(float) var walk_acceleration = 2048
export(float) var walk_deceleration = 2048
export(float) var air_acceleration = 512
export(float) var air_deceleration = 512
export(float) var climb_acceleration = 1024
export(float) var climb_deceleration = 1024
export(float) var walk_speed = 512
export(float) var climb_speed = 256
export(float) var ladder_center_speed = 256
export(float) var gravity = 500

enum State { WALKING, CLIMBING }

var state = State.WALKING
var velocity = Vector2(0, 0)
var ladders = []

func _ready():
	$ladder_sensor.connect("area_entered", self, "ladder_entered")
	$ladder_sensor.connect("area_exited", self, "ladder_exited")

func _physics_process(delta):
	_process_movement(delta)
	_process_bomb_placement()

func _process_movement(delta):
	var direction = Vector2()
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	
	if direction.y != 0 and ladders.size() > 0:
		state = State.CLIMBING
		velocity.y = clamp(velocity.y, -climb_speed, climb_speed)
		collision_mask &= ~2
	elif state == State.CLIMBING and ladders.size() == 0:
		state = State.WALKING
		collision_mask |= 2
	
	if is_on_floor() or state == State.CLIMBING:
		velocity.x = _apply_movement(velocity.x, direction.x, walk_acceleration, walk_deceleration, walk_speed, delta)
	else:
		velocity.x = _apply_movement(velocity.x, direction.x, air_acceleration, air_deceleration, walk_speed, delta)
	
	var ladder_center_velocity = Vector2(0, 0)
	match state:
		State.WALKING:
			velocity.y += delta * gravity
		State.CLIMBING:
			velocity.y = _apply_movement(velocity.y, direction.y, climb_acceleration, climb_deceleration, climb_speed, delta)
			if direction.x == 0:
				var ladder = _find_closest_ladder()
				if ladder:
					var distance_to_ladder = ladder.global_position.x - global_position.x
					ladder_center_velocity.x += delta * ladder_center_speed * distance_to_ladder
	
	move_and_slide(velocity + ladder_center_velocity, Vector2(0, -1))
	
	if is_on_wall():
		velocity.x = 0
	if is_on_floor() or is_on_ceiling():
		velocity.y = 0

func _apply_movement(speed, direction, acceleration, deceleration, max_speed, delta):
	if direction != 0:
		return clamp(speed + direction * delta * acceleration, -max_speed, max_speed)
	else:
		if speed > 0:
			return max(0, speed - delta * deceleration)
		elif speed < 0:
			return min(0, speed + delta * deceleration)
		else:
			return speed

func _find_closest_ladder():
	var closest = null
	var dist = 1e99
	for ladder in ladders:
		var d = global_position.distance_squared_to(ladder.global_position)
		if d < dist:
			dist = d
			closest = ladder
	return closest

func _process_bomb_placement():
	var mouse_position = get_viewport().get_mouse_position()
	var angle = (mouse_position - $ray_cast.global_position).angle()
	$ray_cast.rotation = angle
	$ray_cast.force_raycast_update()
	var can_place_bomb = $ray_cast.is_colliding()
	var ray_end
	if can_place_bomb:
		ray_end = $ray_cast.get_collision_point()
	else:
		ray_end = $ray_cast.to_global($ray_cast.cast_to)
	
	var points = PoolVector2Array()
	points.append(Vector2(0, 0))
	points.append(Vector2((ray_end - $ray_cast.global_position).length(), 0))
	$ray_cast/bomb_line.points = points
	$ray_cast/bomb_line.self_modulate = Color(1, 1, 1, 0.5 if can_place_bomb else 0.1)
	
	if Input.is_action_just_pressed("place_bomb"):
		if can_place_bomb:
			pass # TODO place bomb
		else:
			pass # TODO play sound effect

func ladder_entered(ladder):
	ladders.push_back(ladder)

func ladder_exited(ladder):
	var index = ladders.find(ladder)
	if index >= 0:
		ladders.remove(index)