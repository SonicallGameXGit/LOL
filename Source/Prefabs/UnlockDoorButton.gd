extends TextureButton

func _on_button_up():
	var ui = get_node('../../../')
	ui.hide()
	var playerScript = get_node('../../../../../Player/Player')
	playerScript.canWalk = true
	playerScript.global_position = Vector2(1167.0, -304.0)
	playerScript.get_node('Camera2D').position_smoothing_enabled = false
	
	var killer = load_killer(get_node('../../../').currentDoorCard).instantiate()
	killer.get_node('CharacterBody2D').global_position = Vector2(RandomNumberGenerator.new().randf_range(1068.0, 1265.0), RandomNumberGenerator.new().randf_range(-521.0, -431.0))
	killer.get_node('CharacterBody2D/Sprite2D').z_index = 1
	killer.get_node('CharacterBody2D').type = get_node('../../../').currentDoorCard
	get_tree().get_root().get_node('Scene').add_child(killer)
	playerScript.inFight = true
	
func load_killer(level):
	match level:
		0:
			return load('res://Prefabs/KillerMinorL1.tscn')
		1:
			return load('res://Prefabs/KillerMinorL2.tscn')
		2:
			return load('res://Prefabs/KillerMinorL3.tscn')
		3:
			return load('res://Prefabs/KillerMiddleL1.tscn')
		4:
			return load('res://Prefabs/KillerMiddleL2.tscn')
		5:
			return load('res://Prefabs/KillerMiddleL3.tscn')
