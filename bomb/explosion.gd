extends Node2D

const TEXTS = [
	"BOOM",
	"KABOOM",
	"KABLAM",
	"BANG",
	"KABANG",
]

func _ready():
	$label_parent/label.text = TEXTS[randi() % TEXTS.size()]
	$label_parent/label.add_color_override("font_color", Color(1, 0, 0).linear_interpolate(Color(1, 1, 0), randf()))
	$label_parent.rotation = rand_range(deg2rad(-30), deg2rad(30))
	$animation_player.play("explode")