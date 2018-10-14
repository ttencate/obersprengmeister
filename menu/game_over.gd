extends Node2D

signal retry
signal next_level

var dismissed = false

func _ready():
	$retry.connect("pressed", self, "_retry_pressed")
	$next_level.connect("pressed", self, "_next_level_pressed")

func init(stars, damage, survived, has_next_level):
	var outcome
	var explanation
	var success = false
	if not survived:
		outcome = "Workplace Accident"
		if stars == 0:
			explanation = "You died in an explosion. Stay away from exploding TNT next time!"
		else:
			explanation = "You may have leveled the building, but you also blew yourself up. Try not to do that."
	elif damage > 0:
		outcome = "Insurance Trouble"
		explanation = "Some buildings were damaged that shouldn't be. Be more careful!"
	elif stars == 0:
		outcome = "Not Enough Boom"
		explanation = "It may have looked spectacular, but the building didn't get leveled sufficiently. Try to use more explosives, or place them better!"
	else:
		outcome = "FLATTENED!"
		if has_next_level:
			explanation = "You totally blew it. And that's a good thing!"
		else:
			explanation = "Congratulations! You beat all the levels!"
		success = true
	
	var star_sprites = $stars.get_children()
	for i in range(1, 4):
		if stars >= i:
			star_sprites[i - 1].texture = preload("res://menu/star_filled.svg")
			if success:
				star_sprites[i - 1].self_modulate = Color(1, 1, 1)
	
	$outcome.text = outcome
	$explanation.text = explanation
	
	$next_level.visible = has_next_level
	$next_level.disabled = !success
	
	dismissed = false

func animate_in():
	show()
	$animation_player.play("enter")

func animate_out():
	dismissed = true
	$animation_player.play("leave")

func _retry_pressed():
	if dismissed:
		return
	print("retry")
	emit_signal("retry")
	animate_out()

func _next_level_pressed():
	if dismissed:
		return
	print("next level")
	emit_signal("next_level")
	animate_out()