extends Node2D

var NUM_LEVELS = 5
var current_level = 1

onready var game_over = $hud/game_over
onready var title_screen = $hud/title_screen
onready var previous_level_button = $hud/buttons/previous_level_button
onready var next_level_button = $hud/buttons/next_level_button
onready var restart_button = $hud/buttons/restart_button

func _ready():
	OS.set_window_maximized(true)
	
	game_over.connect("retry", self, "_retry")
	game_over.connect("next_level", self, "_next_level")
	game_over.visible = false
	
	title_screen.connect("dismissed", self, "_instance_level")
	title_screen.visible = true
	title_screen.animate_in()
	
	previous_level_button.connect("pressed", self, "_previous_level")
	next_level_button.connect("pressed", self, "_next_level")
	restart_button.connect("pressed", self, "_instance_level")
	
	previous_level_button.visible = false
	next_level_button.visible = false
	restart_button.visible = false

func _update_buttons():
	previous_level_button.visible = current_level > 1
	next_level_button.visible = current_level < NUM_LEVELS
	restart_button.visible = true

func _instance_level():
	for child in $level.get_children():
		child.queue_free()
	
	var level = load("res://levels/level_%02d.tscn" % [current_level]).instance()
	$level.add_child(level)
	
	level.connect("completed", self, "_level_completed")
	level.connect("demolishing", self, "_level_demolishing")
	
	$music.volume_db = -3
	if not $music.playing:
		$music.play()
	
	_update_buttons()

func _level_demolishing():
	$music.volume_db = -12

func _level_completed(stars, damage, survived):
	$music.volume_db = -12
	
	game_over.init(stars, damage, survived, current_level < NUM_LEVELS)
	game_over.animate_in()

func _retry():
	_instance_level()

func _previous_level():
	if current_level > 1:
		current_level -= 1
	_instance_level()

func _next_level():
	if current_level < NUM_LEVELS:
		current_level += 1
	_instance_level()