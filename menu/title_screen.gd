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