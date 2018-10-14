extends Area2D
tool

export(Texture) var stars_texture = null setget _set_stars_texture
export(int) var stars = 0

signal achieved

var overlapping_bodies = []

func _ready():
	_set_stars_texture(stars_texture)
	if Engine.editor_hint:
		return
	
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")

func _body_entered(body):
	# print("%d: %s entered" % [stars, body.get_path()])
	if is_target_body(body):
		overlapping_bodies.push_back(body)

func _body_exited(body):
	# print("%d: %s exited" % [stars, body.get_path()])
	var i = overlapping_bodies.find(body)
	if i >= 0:
		overlapping_bodies.remove(i)
	if overlapping_bodies.size() == 0:
		achieve()

func is_target_body(body):
	return body.has_method("is_target_block") and body.is_target_block()

func achieve():
	disconnect("body_entered", self, "_body_entered")
	disconnect("body_exited", self, "_body_exited")
	print("achieved %d stars" % stars)
	$line_sprite.self_modulate = Color(1, 1, 1, 1)
	$stars_sprite.self_modulate = Color(1, 1, 1, 1)
	emit_signal("achieved", stars)

func _set_stars_texture(texture):
	stars_texture = texture
	if has_node("stars_sprite"):
		$stars_sprite.texture = texture