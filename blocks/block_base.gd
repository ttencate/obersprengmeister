extends RigidBody2D

export(Color) var color
export(bool) var is_target

func is_target_block():
	return is_target