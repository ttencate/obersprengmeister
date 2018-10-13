extends KinematicBody2D

export(float) var delay = 5
export(float) var strength = 1000

func _ready():
	$timer.connect("timeout", self, "explode")
	$timer.wait_time = delay

func _process(delta):
	$display.text = '%d' % floor($timer.time_left)

func place(from, direction):
	global_position = from
	move_and_collide(direction)
	collision_layer = 0
	collision_mask = 0

func explode():
	var space = get_world_2d().direct_space_state
	var num_rays = 24
	for i in range(0, num_rays):
		var global_direction = Vector2(1, 0).rotated(2 * PI * i / num_rays)
		var result = space.intersect_ray(global_position, global_position + 1920 * global_direction, [self])
		if result.has("collider"):
			var collider = result.collider
			if collider.has_method("apply_impulse"):
				var offset = collider.to_local(result.position)
				var impulse = strength / num_rays * global_direction
				collider.apply_impulse(offset, impulse)
	
	var explosion = preload("res://bomb/explosion.tscn").instance()
	explosion.position = self.position
	explosion.scale = Vector2(0.7, 0.7)
	get_parent().add_child(explosion)
	
	queue_free()