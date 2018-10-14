extends RigidBody2D

export(Color) var color
export(bool) var is_target

var initial_transform

func _ready():
	initial_transform = global_transform

func is_target_block():
	return is_target

func civilian_damage():
	if is_target:
		return 0
	var a = -0.5 * $sprite.texture.get_size()
	var b = 0.5 * $sprite.texture.get_size()
	var final_transform = global_transform
	var damage = (
		(initial_transform * a).distance_to(final_transform * a) +
		(initial_transform * b).distance_to(final_transform * b)
	)
	if damage < 32:
		return 0
	return damage