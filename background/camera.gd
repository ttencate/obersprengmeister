extends Camera2D

export(float) var out_zoom = 1.5
export(NodePath) var remote_transform_node = null

signal zoomed_in_to_player
signal zoomed_out_to_overview

onready var initial_position = position
onready var remote_transform = get_node(remote_transform_node)

var shake_duration = 0.2
var shake_amplitude = 24
var shake_remaining = 0

func _ready():
	$zoom_in_tween.connect("tween_started", self, "_zoom_in_tween_started")
	$zoom_in_tween.connect("tween_completed", self, "_zoom_in_tween_completed")
	$zoom_out_tween.connect("tween_started", self, "_zoom_out_tween_started")
	$zoom_out_tween.connect("tween_completed", self, "_zoom_out_tween_completed")
	smoothing_enabled = false
	zoom = Vector2(out_zoom, out_zoom)
	call_deferred("_set_track_player", false)

func _process(delta):
	if shake_remaining > 0:
		var amplitude = shake_remaining * shake_amplitude
		offset = Vector2(rand_range(-1, 1) * amplitude, rand_range(-1, 1) * amplitude)
		shake_remaining = max(0, shake_remaining - delta / shake_duration)
	else:
		offset = Vector2()

func zoom_in_to_player(duration, delay):
	$zoom_out_tween.stop_all()
	$zoom_in_tween.remove_all()
	$zoom_in_tween.interpolate_property(self, "zoom", zoom, Vector2(1.0, 1.0), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
	$zoom_in_tween.interpolate_property(self, "position", position, remote_transform.global_position, duration, Tween.TRANS_SINE, Tween.EASE_OUT_IN, delay)
	$zoom_in_tween.start()

func zoom_out_to_overview(duration, delay):
	$zoom_in_tween.stop_all()
	$zoom_out_tween.remove_all()
	$zoom_out_tween.interpolate_property(self, "zoom", zoom, Vector2(out_zoom, out_zoom), duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
	$zoom_out_tween.interpolate_property(self, "position", position, initial_position, duration, Tween.TRANS_SINE, Tween.EASE_OUT_IN, delay)
	$zoom_out_tween.start()

func _set_track_player(track):
	if remote_transform:
		remote_transform.update_position = track

func _zoom_in_tween_started(object, key):
	pass

func _zoom_in_tween_completed(object, key):
	_set_track_player(true)
	smoothing_enabled = true
	emit_signal("zoomed_in_to_player")

func _zoom_out_tween_started(object, key):
	_set_track_player(false)

func _zoom_out_tween_completed(object, key):
	emit_signal("zoomed_out_to_overview")
	smoothing_enabled = false

func shake():
	shake_remaining += 1