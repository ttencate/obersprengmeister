extends Node2D

var leaving = false

signal dismissed

func animate_in():
	$animation_player.play("enter")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed() and not leaving:
		leaving = true
		$animation_player.play("leave")
		emit_signal("dismissed")
		
		var explosion = preload("res://bomb/explosion.tscn").instance()
		explosion.position = Vector2(960, 540)
		explosion.scale = Vector2(1.5, 1.5)
		get_parent().add_child(explosion)