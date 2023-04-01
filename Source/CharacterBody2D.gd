extends CharacterBody2D


const SPEED = 10000.0
const SPEED_SHARPNESS = 12.0
const DAMAGE_SHARPNESS = 4.0
const CAMERA_SHAKE_SHARPNESS = 6.0
const GENE_CHANGE_SPEED = 3.0

var heartbeats = [
	load('res://Sounds/Heartbeat1.ogg'),
	load('res://Sounds/Heartbeat2.ogg'),
	load('res://Sounds/Heartbeat3.ogg'),
	load('res://Sounds/Heartbeat4.ogg')
]
var keyEquips = [
	load('res://Sounds/KeyEquip1.ogg'),
	load('res://Sounds/KeyEquip2.ogg'),
	load('res://Sounds/KeyEquip3.ogg')
]

var bulletPrefab = load('res://Prefabs/Bullet.tscn')
var noise = FastNoiseLite.new()
var canWalk = true
var globalLevel = 1
var localLevel = 0
var keys = 0
var health = 100
var time = 0.0
var lastFireTime = 0.2
var lastDeathTime = 0.0
var lastHeartbeatTime = 0.08
var rebirthes = 0
var geneColor = Color(0.0, 0.0, 0.0)
var secretEnabled = false
var inFight = false
var lastBulletDirection = Vector2(0.0, 0.0)

func update_cards():
	var doorUi : Control = get_node('../../CanvasLayer/DoorOpenUI')
	get_node('../../CanvasLayer/UI/LeftTopCornerHorizontal/KeysLabel').text = str(keys)
	
	var playerCard = get_node('../../CanvasLayer/DoorOpenUI/BackgroundPanel/InteractionPanel/PlayerCard')
	playerCard.texture = doorUi.load_texture(globalLevel * 3 + localLevel)
func _ready():
	generate_gene()
	
	var doorUi : Control = get_node('../../CanvasLayer/DoorOpenUI')
	doorUi.hide()
	get_node('../../CanvasLayer/UI/LeftTopCornerHorizontal/KeysLabel').text = str(keys)
	
	var playerCard = get_node('../../CanvasLayer/DoorOpenUI/BackgroundPanel/InteractionPanel/PlayerCard')
	playerCard.texture = doorUi.load_texture(globalLevel * 3 + localLevel)
func _process(delta):
	get_node('Sprite2D').modulate = lerp(get_node('Sprite2D').modulate, geneColor, GENE_CHANGE_SPEED * (8.0 if secretEnabled else 1.0) * delta)
	get_node('../../CanvasLayer/UI/HealthIcon').modulate = lerp(get_node('../../CanvasLayer/UI/HealthIcon').modulate, geneColor, GENE_CHANGE_SPEED * (8.0 if secretEnabled else 1.0) * delta)
	get_node('PointLight2D').color = lerp(get_node('PointLight2D').color, geneColor, GENE_CHANGE_SPEED * (8.0 if secretEnabled else 1.0) * delta)
	
	time += delta
	get_node('../../CanvasLayer/UI/RebirthButton').visible = globalLevel >= 1 && localLevel >= 2 && !inFight
	if canWalk:
		var direction = Vector2(0.0, 0.0)
	
		direction.x += 1.0 if Input.is_action_pressed('right') else 0.0
		direction.x -= 1.0 if Input.is_action_pressed('left') else 0.0
		direction.y += 1.0 if Input.is_action_pressed('down') else 0.0
		direction.y -= 1.0 if Input.is_action_pressed('up') else 0.0
		
		if Input.is_action_just_pressed('secret'):
			secretEnabled = !secretEnabled
		if secretEnabled:
			generate_normalized_gene()
		
		if Input.is_action_pressed('fire') && time - lastFireTime >= 0.3:
			if velocity.normalized().length() > 0.0:
				lastBulletDirection = velocity.normalized()
			var bullet = bulletPrefab.instantiate()
			bullet.global_position = global_position
			bullet.get_node('CharacterBody2D').velocity = lastBulletDirection * 160.0
			bullet.get_node('CharacterBody2D/Sprite2D').modulate = geneColor
			get_node('../../').add_child(bullet)
			lastFireTime = time
		
		velocity = lerp(velocity, direction.normalized() * SPEED * delta, SPEED_SHARPNESS * delta)
		
		var lowResDirX = round(direction.x * 100.0) / 100.0
		var lowResDirY = round(direction.y * 100.0) / 100.0
		
		var animationPlayer = get_node('AnimationPlayer')
		if sqrt(pow(lowResDirX, 2.0) + pow(lowResDirY, 2.0)) > 0.0:
			get_node('../../MonsterPlayer2D').global_position = global_position
			get_node('../../MonsterPlayer2D').stream_paused = false
			animationPlayer.play('PlayerRun')
		else:
			get_node('../../MonsterPlayer2D').stream_paused = true
			animationPlayer.stop()
			get_node('Sprite2D').frame = 0
		if lowResDirX != 0.0:
			get_node('Sprite2D').flip_h = lowResDirX < 0.0
		
		get_node('../../CanvasLayer/UI/HealthIcon').texture.speed_scale = 4.0 - (health / 30.0)
		get_node('Camera2D').offset = lerp(get_node('Camera2D').offset, Vector2(noise.get_noise_1d(time * 10000.0), noise.get_noise_1d(time * 10000.0 + 45.0)) * (20.0 - health / 5.0), CAMERA_SHAKE_SHARPNESS * delta)
		
		var vignette = get_node('../../CanvasLayer/UI/Vignette')
		vignette.modulate.a = lerp(vignette.modulate.a, 1.0 - health / 100.0, DAMAGE_SHARPNESS * delta)
		
		if health <= 0.0:
			global_position = Vector2(0.0, 0.0)
			get_node('Camera2D').position_smoothing_enabled = false
			inFight = false
			if keys <= 0:
				var keyInstance = load('res://Prefabs/Key.tscn').instantiate()
				keyInstance.global_position = Vector2(164.0, 30.0)
				get_node('../../').add_child(keyInstance)
		if health < 100.0:
			health += 1.5 * delta
		else:
			health = 100.0
		if time - lastDeathTime >= 0.2:
			get_node('Camera2D').position_smoothing_enabled = true
			lastDeathTime = time
		
		move_and_slide()
	if time - lastHeartbeatTime >= 1.25 / (4.0 - (health / 30.0)):
		lastHeartbeatTime = time
		get_node('../../HeartbeatPlayer2D').stream = heartbeats.pick_random()
		get_node('../../HeartbeatPlayer2D').volume_db = (1.0 - (health / 100.0)) * 12.0
		get_node('../../HeartbeatPlayer2D').playing = true
func _on_door_area_body_exited(body):
	var doorUi = get_node('../../CanvasLayer/DoorOpenUI')
	doorUi.hide()
	canWalk = true
	get_node('Camera2D').position_smoothing_enabled = true
func _on_door_area_body_entered(body):
	var doorUi = get_node('../../CanvasLayer/DoorOpenUI')
	
	if !doorUi.visible && keys > 0:
		keys -= 1
		
		var pos = Vector2(floor(body.global_position.x), floor(body.global_position.y))
		
		doorUi.show()
		doorUi.shuffle_cards(self, pos)
		canWalk = false
		get_node('../../CanvasLayer/UI/LeftTopCornerHorizontal/KeysLabel').text = str(keys)
func _on_key_area_body_entered(body):
	get_node('../../KeyPlayer2D').global_position = body.global_position
	get_node('../../KeyPlayer2D').stream = keyEquips.pick_random()
	get_node('../../KeyPlayer2D').playing = true
	body.queue_free()
	keys += 1
	get_node('../../CanvasLayer/UI/LeftTopCornerHorizontal/KeysLabel').text = str(keys)
func _on_damage_area_body_entered(body):
	health -= body.damage
func generate_gene():
	geneColor.r = RandomNumberGenerator.new().randf_range(0.0, 1.0)
	geneColor.g = RandomNumberGenerator.new().randf_range(0.0, 1.0)
	geneColor.b = RandomNumberGenerator.new().randf_range(0.0, 1.0)
func generate_normalized_gene():
	var tempColor = Vector3(0.0, 0.0, 0.0)
	tempColor.x = RandomNumberGenerator.new().randf_range(0.0, 1.0)
	tempColor.y = RandomNumberGenerator.new().randf_range(0.0, 1.0)
	tempColor.z = RandomNumberGenerator.new().randf_range(0.0, 1.0)
	
	geneColor = Color(tempColor.normalized().x, tempColor.normalized().y, tempColor.normalized().z)
