extends CharacterBody2D

const SPEED = 5000.0
const SHARPNESS = 4.0
const BOUNCE_POWER = 150.0

var gunShots = [
	load('res://Sounds/GunShot1.ogg'),
	load('res://Sounds/GunShot2.ogg'),
	load('res://Sounds/GunShot3.ogg')
]
var direction = Vector2(0.0, 0.0)
var health = 100.0
var lastKickTime = 0.0
var lastShootTime = 0.0
var lastShootAnimTime = 0.0
var lastLightTime = 0.0
var time = 0.0
var type = 0

func _process(delta):
	time += delta
	
	if round(direction.x * 100.0) / 100.0 != 0.0:
		get_node('Sprite2D').flip_h = round(-(global_position - get_node('../../Player/Player').position).normalized().x * 100.0) / 100.0 < 0.0
	
	velocity = lerp(velocity, direction * SPEED * delta, SHARPNESS * delta)
	
	move_and_slide()
	direction = (-1.0 if type < 3 else (1.0 if get_node('../../Player/Player').position.distance_to(global_position) < 75.0 else -1.0)) * (global_position - get_node('../../Player/Player').position).normalized()
	if type >= 3:
		get_node('PointLight2D').offset.x = -4.0 if get_node('Sprite2D').flip_h else 12.0
	if get_node('../../Player/Player').health <= 0.0:
		get_node('../../Player/Player').health = 100.0
		queue_free()
	if health <= 0.0:
		get_node('../../Player/Player').localLevel += max(get_node('../../CanvasLayer/DoorOpenUI').currentDoorCard - get_node('../../Player/Player').localLevel - get_node('../../Player/Player').globalLevel * 3, 1)
		if get_node('../../Player/Player').localLevel > 2 && get_node('../../Player/Player').globalLevel < 1:
			get_node('../../Player/Player').localLevel = 0
			get_node('../../Player/Player').globalLevel += 1
		else:
			get_node('../../Player/Player').localLevel = clamp(get_node('../../Player/Player').localLevel, 0, 2)
		get_node('../../Player/Player').keys += get_node('../../Player/Player').globalLevel * 2 + 2
		get_node('../../CanvasLayer/UI/LeftTopCornerHorizontal/KeysLabel').text = str(get_node('../../Player/Player').keys)
		get_node('../../Player/Player').update_cards()
		get_node('../../Player/Player').global_position = Vector2(0.0, 0.0)
		get_node('../../Player/Player/Camera2D').position_smoothing_enabled = false
		get_node('../../Player/Player').lastDeathTime = get_node('../../Player/Player').time
		get_node('../../Player/Player').inFight = false
		
		queue_free()
	if type < 3:
		if time - lastKickTime >= 0.6:
			get_node('AnimationPlayer').play('KillerRun')
	elif time - lastShootTime >= 0.25:
		get_node('AnimationPlayer').play('KillerRun')
	if type >= 3 && time - lastShootTime >= 0.35:
		var bullet = load('res://Prefabs/KillerBullet.tscn').instantiate()
		bullet.global_position = global_position
		bullet.get_node('CharacterBody2D').velocity = -((global_position - get_node('../../Player/Player').position).normalized() * SPEED * 0.01)
		bullet.get_node('CharacterBody2D').damage = (type - 2.0) * 25.0 - 15.0
		get_node('../../').add_child(bullet)
		get_node('AnimationPlayer').play('KillerKick')
		lastShootTime = time
		get_node('PointLight2D').enabled = true
		lastLightTime = time
		get_node('../../GunPlayer2D').stream = gunShots.pick_random()
		get_node('../../GunPlayer2D').pitch_scale = RandomNumberGenerator.new().randf_range(0.8, 1.2)
		get_node('../../GunPlayer2D').global_position = global_position
		get_node('../../GunPlayer2D').playing = true
	if type >= 3 && time - lastLightTime >= 0.15:
		get_node('PointLight2D').enabled = false
func _on_kick_area_body_entered(body):
	direction = -direction * BOUNCE_POWER
	move_and_slide()
	match type:
		0:
			body.health -= 10
		1:
			body.health -= 20
		2:
			body.health -= 40
	get_node('AnimationPlayer').play('KillerKick')
	lastKickTime = time
func _on_damage_area_body_entered(body):
	if type < 3:
		health -= 10.0 / (type + 1.0) * ((get_node('../../Player/Player').localLevel + get_node('../../Player/Player').globalLevel * 3.0 + 2.0) / 2.0)
	else:
		health -= 30.0 / (type + 1.0) * ((get_node('../../Player/Player').localLevel + get_node('../../Player/Player').globalLevel * 3.0 + 2.0) / 2.0)
	body.queue_free()
