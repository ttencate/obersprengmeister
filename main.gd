extends Node2D

var NUM_LEVELS = 5
var current_level = 1

onready var game_over = $hud/game_over
onready var title_screen = $hud/title_screen

func _ready():
	OS.set_window_maximized(true)
	
	game_over.connect("retry", self, "_retry")
	game_over.connect("next_level", self, "_next_level")
	game_over.visible = false
	
	title_screen.connect("dismissed", self, "_instance_level")
	title_screen.visible = true
	title_screen.animate_in()

func _instance_level():
	for child in $level.get_children():
		child.queue_free()
	
	var level = load("res://levels/level_%02d.tscn" % [current_level]).instance()
	$level.add_child(level)
	
	level.connect("completed", self, "_level_completed")
	level.connect("demolishing", self, "_level_demolishing")
	
	$music.volume_db = -6
	if not $music.playing:
		$music.play()

func _level_demolishing():
	$music.volume_db = -12

func _level_completed(stars, damage, survived):
	$music.volume_db = -12
	
	game_over.init(stars, damage, survived, current_level < NUM_LEVELS)
	game_over.animate_in()

func _retry():
	_instance_level()

func _next_level():
	if current_level < NUM_LEVELS:
		current_level += 1
	_instance_level()