extends TextureButton

func _on_button_up():
	var ui = get_node('../../../')
	ui.hide()
	var playerScript = get_node('../../../../../Player/Player')
	playerScript.canWalk = true
