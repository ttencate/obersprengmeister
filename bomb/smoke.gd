extends Sprite

onready var velocity = Vector2(300 * rand_range(0.8, 1.2), 0).rotated(rand_range(0, 2 * PI))
onready var age = rand_range(0.1, 0.3)
onready var lifetime = 1.0

func _ready():
	position += age * velocity

func _process(delta):
	age += delta
	velocity *= pow(0.5, delta)
	position += delta * velocity
	var scale = 1.5 * age / lifetime
	self.scale = Vector2(scale, scale)
	var alpha = clamp(4 * (1 - age / lifetime), 0, 1)
	self_modulate = Color(1, 1, 1, alpha)