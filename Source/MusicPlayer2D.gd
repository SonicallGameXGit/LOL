extends AudioStreamPlayer2D

var music = [
	load('res://Sounds/Ambient.ogg'),
	load('res://Sounds/DarkRiddim.ogg'),
	load('res://Sounds/Ancient.ogg')
]

func _process(delta):
	if !playing:
		stream = music.pick_random()
		playing = true
