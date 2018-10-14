extends Node2D

var NUM_LEVELS = 2
var current_level = 2

onready var game_over = $hud/game_over

func _ready():
	game_over.connect("retry", self, "_retry")
	game_over.connect("next_level", self, "_next_level")
	
	OS.set_window_maximized(true)
	
	game_over.visible = false
	_instance_level()

func _instance_level():
	for child in $level.get_children():
		child.queue_free()
	
	var level = load("res://levels/level_%02d.tscn" % [current_level]).instance()
	$level.add_child(level)
	
	level.connect("completed", self, "_level_completed")

func _level_completed(stars, damage, survived):
	game_over.init(stars, damage, survived, current_level < NUM_LEVELS)
	game_over.animate_in()

func _retry():
	_instance_level()

func _next_level():
	if current_level < NUM_LEVELS:
		current_level += 1
	_instance_level()