extends Node2D

var any_bombs_placed = false
var stars = 0

func _ready():
	$player.connect("placed_bomb", self, "_player_placed_bomb")
	$player.connect("exploded", self, "_player_exploded")
	$safe_zone.connect("body_entered", self, "_safe_zone_entered")
	$target_area_1.connect("achieved", self, "_target_achieved")
	$target_area_2.connect("achieved", self, "_target_achieved")
	$target_area_3.connect("achieved", self, "_target_achieved")
	
	$camera.zoom_in_to_player(3.0, 1.0)
	$camera.connect("zoomed_in_to_player", $player, "start")

func _player_placed_bomb(bomb):
	any_bombs_placed = true
	bomb.connect("exploded", self, "_bomb_exploded")

func _bomb_exploded(bomb):
	var explosion = preload("res://bomb/explosion.tscn").instance()
	$explosions.add_child(explosion)
	explosion.global_position = bomb.global_position
	var scale = 0.0007 * bomb.strength
	explosion.scale = Vector2(scale, scale)
	
	$camera.shake()

func _player_exploded(bomb):
	_bomb_exploded(bomb)
	$player.queue_free()
	# TODO lose screen

func _safe_zone_entered(object):
	if object != $player:
		return
	print("entered safe zone")
	
	if not any_bombs_placed:
		print("no bombs placed")
		# TODO show instructions
		return
	
	get_tree().call_group("ladders", "fade_out")
	
	$camera.zoom_out_to_overview(3.0, 0.0)
	
	$player.cower()
	
	var bombs = get_tree().get_nodes_in_group("bombs")
	
	var min_time_left  = 1e99
	for bomb in bombs:
		min_time_left = min(min_time_left, bomb.time_left())
	
	var time_to_kill = min_time_left - 3
	if time_to_kill > 0:
		for bomb in bombs:
			bomb.delay = bomb.time_left() - time_to_kill
			bomb.start()

func _target_achieved(stars):
	if stars > self.stars:
		self.stars = stars
		# TODO eventually win screen