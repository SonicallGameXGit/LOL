extends CharacterBody2D

const ROTATION_SPEED = 0.3

var time = 0.0
var damage = 0.0

func _process(delta):
	time += delta
	if time >= 3.0:
		queue_free()
	
	global_position += velocity * delta
