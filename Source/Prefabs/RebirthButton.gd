extends TextureButton

func _on_button_up():
	get_node('../../../Player/Player').rebirthes += 1
	get_node('../RightTopCornerHorizontal/RebirthesLabel').text = str(get_node('../../../Player/Player').rebirthes)
	get_node('../../../Player/Player').localLevel = 0
	get_node('../../../Player/Player').globalLevel = 0
	get_node('../../../Player/Player').keys = 0
	get_node('../../../Player/Player').update_cards()
	
	var keyInstance = load('res://Prefabs/Key.tscn').instantiate()
	keyInstance.global_position = Vector2(164.0, 30.0)
	get_node('../../../').add_child(keyInstance)
	
	get_node('../../../RebirthPlayer2D').pitch_scale = RandomNumberGenerator.new().randf_range(0.9, 1.1)
	get_node('../../../RebirthPlayer2D').playing = true
	get_node('../../../Player/Player').generate_gene()
