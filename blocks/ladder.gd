tool
extends Area2D

export(float) var height = 256 setget _set_height

func _ready():
	_update_height()

func _set_height(h):
	height = h
	if is_inside_tree():
		_update_height()

func _update_height():
	var shape = RectangleShape2D.new()
	shape.extents = Vector2($collision_shape_2d.shape.extents.x, height / 2)
	$collision_shape_2d.shape = shape
	$collision_shape_2d.position.y = -height / 2
	$top.position.y = -height - 2
	$bottom.position.y = -($bottom.texture.get_height() - 2)
	$mid.position.y = $top.position.y + $top.texture.get_height()
	$mid.region_rect.size.y = $bottom.position.y - $mid.position.y

func fade_out():
	$fade_out_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$fade_out_tween.connect("tween_completed", self, "_fade_out_completed")
	$fade_out_tween.start()

func _fade_out_completed(object, key):
	queue_free()