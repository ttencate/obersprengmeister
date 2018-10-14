extends Node2D

signal demolishing
signal completed

var any_bombs_placed = false
var stars = 0

var active_bombs = []
var is_completed = false

func _ready():
	$player.connect("placed_bomb", self, "_player_placed_bomb")
	$player.connect("died", self, "_player_died")
	$safe_zone.connect("body_entered", self, "_safe_zone_entered")
	$target_area_1.connect("achieved", self, "_target_achieved")
	$target_area_2.connect("achieved", self, "_target_achieved")
	$target_area_3.connect("achieved", self, "_target_achieved")
	
	$camera.zoom_in_to_player(3.0, 1.0)
	$camera.connect("zoomed_in_to_player", $player, "start")
	
	$check_completion_timer.connect("timeout", self, "_check_completion")

func _enter_tree():
	$animation_player.play("enter")
	$camera.make_current()

func _player_placed_bomb(bomb):
	any_bombs_placed = true
	bomb.connect("exploded", self, "_bomb_exploded")
	active_bombs.push_back(bomb)

func _bomb_exploded(bomb):
	var explosion = preload("res://bomb/explosion.tscn").instance()
	$explosions.add_child(explosion)
	explosion.global_position = bomb.global_position
	var scale = 0.7 # 0.0002 * bomb.strength
	explosion.scale = Vector2(scale, scale)
	
	$camera.shake()
	
	active_bombs.erase(bomb)
	
	if has_node("player") and $player.takes_input:
		$player.cower()

func _player_died():
	pass

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
			if bomb.is_started():
				bomb.delay = bomb.time_left() - time_to_kill
				bomb.start()
	
	$alarm.play()
	
	emit_signal("demolishing")

func _check_completion():
	if is_completed:
		return
	
	var survived = not $player.dead
	
	# Still waiting for bombs? Not completed.
	if survived and (not any_bombs_placed or active_bombs.size() > 0):
		return
	
	# Still waiting for blocks to come to rest? Not completed.
	for block in get_tree().get_nodes_in_group("blocks"):
		if not _is_resting(block):
			return
	
	var damage = 0
	for block in get_tree().get_nodes_in_group("blocks"):
		if block.has_method("is_target_block") and not block.is_target_block():
			damage += block.civilian_damage()
	
	is_completed = true
	print("level completed with %d stars, $%d damage, survival: %s" % [stars, damage, survived])
	emit_signal("completed", stars, damage, survived)

func _is_resting(block):
	if not (block is RigidBody2D):
		return true
	if block.global_position.y > 1080:
		return true # Block fell off the screen.
	if block.sleeping:
		return true
	if block.linear_velocity.length() < 10 and abs(block.angular_velocity) < deg2rad(1):
		return true
	return false

func _target_achieved(stars):
	if stars > self.stars:
		self.stars = stars