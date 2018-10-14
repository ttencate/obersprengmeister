extends Node2D

export(float) var delay = 5 setget _set_delay
export(float) var strength = 4000

signal exploded

func _ready():
	$timer.connect("timeout", self, "explode")

func start():
	print("bomb started with delay %f" % [delay])
	$timer.wait_time = delay
	$timer.start()

func is_started():
	return !$timer.is_stopped()

func _process(delta):
	$display.text = '%d' % ceil(time_left())

func place(position, normal, parent):
	parent.add_child(self)
	var offset = 10
	global_position = position + offset * normal
	global_rotation = 0 # normal.angle()

func explode():
	var space = get_world_2d().direct_space_state
	var num_rays = 48
	for i in range(0, num_rays):
		var global_direction = Vector2(1, 0).rotated(2 * PI * i / num_rays)
		var mask = 1 | 2 | 8 # walls, floors, player
		var result = space.intersect_ray(global_position, global_position + 1920 * global_direction, [self], mask)
		if result.has("collider"):
			var collider = result.collider
			if collider.has_method("apply_impulse"):
				var offset = collider.to_local(result.position)
				var impulse = strength / num_rays * global_direction
				collider.apply_impulse(offset, impulse)
			if collider.has_method("take_damage") and result.position.distance_to(collider.global_position) <= 256:
				collider.take_damage(self)
	
	emit_signal("exploded", self)
	
	queue_free()

func time_left():
	return delay if $timer.is_stopped() else $timer.time_left

func _set_delay(d):
	d = clamp(d, 1, 99)
	delay = d