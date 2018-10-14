extends Sprite
tool

func _process(delta):
	var parent = get_parent()
	if not parent:
		return
	var c = parent.color
	if parent.is_target:
		c = c.linear_interpolate(Color(0.5, 0.5, 0.5), 0.8).darkened(0.5)
	self_modulate = c