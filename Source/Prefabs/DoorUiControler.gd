extends Control

var randomSpawnOffset = RandomNumberGenerator.new().randi()
var currentDoorCard = 0

func shuffle_cards(player : CharacterBody2D, offset : Vector2):
	var random = RandomNumberGenerator.new()
	random.seed = offset.x + offset.y + randomSpawnOffset + player.globalLevel * 3 + player.localLevel
	var randomValue = random.randi_range(player.globalLevel * 3, player.globalLevel * 3 + 2)
	get_node('BackgroundPanel/InteractionPanel/DoorCard').texture = load_texture(randomValue)
	currentDoorCard = randomValue
	
	if player.localLevel + player.globalLevel * 3 < randomValue:
		get_node('BackgroundPanel/InteractionPanel/Comparison').text = '<'
	elif player.localLevel + player.globalLevel * 3 == randomValue:
		get_node('BackgroundPanel/InteractionPanel/Comparison').text = '='
	else:
		get_node('BackgroundPanel/InteractionPanel/Comparison').text = '>'
	get_node('BackgroundPanel/InteractionPanel/ChanceToWin').text = 'Chance to win: ' + str(int(100.0 + (player.localLevel + player.globalLevel * 3 - randomValue) / 3.0 * 100.0) / 2.0) + '%'
	get_node('BackgroundPanel/InteractionPanel/ChanceToWin').set('theme_override_colors/font_color', lerp(Color(0.87, 0.2, 0.18), Color(0.2, 0.87, 0.18), 1.0 + (player.localLevel + player.globalLevel * 3 - randomValue) / 3.0))
	

func load_texture(id):
	match id:
		0:
			return load('res://Sprites/GUI/MinorCardL1.png')
		1:
			return load('res://Sprites/GUI/MinorCardL2.png')
		2:
			return load('res://Sprites/GUI/MinorCardL3.png')
		3:
			return load('res://Sprites/GUI/MiddleCardL1.png')
		4:
			return load('res://Sprites/GUI/MiddleCardL2.png')
		5:
			return load('res://Sprites/GUI/MiddleCardL3.png')
