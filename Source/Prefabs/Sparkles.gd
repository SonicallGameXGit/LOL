extends Sprite2D

func _process(delta):
	get_node('AnimationPlayer').play('SparklesIdle')
