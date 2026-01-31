extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMPS = 2
const BULLET = preload("res://bullet/bullet.tscn")
const SHOOT_SOUND = preload("res://bullet/shoot.mp3")
const BULLET_OFFSET_X = 40 # Adjust this value to move the bullet left or right
const BULLET_OFFSET_Y = -20 # Adjust this value to move the bullet up or down

var jumps = 0
var charge_time = 0.0
var max_charge = 2.0  # 最大2秒

@onready var sprite = $Sprite2D
@onready var camera = get_parent().get_node("Camera2D")
@onready var charge_circle = $AnimatedCircle

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = true

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps = 0

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if jumps < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jumps += 1
	
	# Handle shooting
	if Input.is_action_pressed("shoot"):
		charge_time += delta
		charge_circle.update_charge(charge_time)  # 更新光環 [web:40]

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false
	
	sprite.flip_h = not facing_right
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	camera.global_position.x = global_position.x
	move_and_slide()

func _input(event):
	if event.is_action_pressed("shoot"):  # 按住射擊鍵
		charge_time = 0.0
	
	if event.is_action_released("shoot"):
		shoot_bullet(clamp(charge_time, 0.0, max_charge))  # 發射集氣子彈
		charge_time = 0.0
		charge_circle.update_charge(0.0)  # 重置光環

func shoot_bullet(charge_level: float):
	
	var bullet = BULLET.instantiate()

	if facing_right:
		bullet.velocity = Vector2(bullet.SPEED, 0)
		bullet.position = position + Vector2(BULLET_OFFSET_X, BULLET_OFFSET_Y)
	else:
		bullet.velocity = Vector2(-bullet.SPEED, 0)
		bullet.position = position + Vector2(-BULLET_OFFSET_X, BULLET_OFFSET_Y)
	
	bullet.charge_level = charge_level  # 傳遞集氣值
	get_parent().add_child(bullet)

	var sound = AudioStreamPlayer.new()
	sound.stream = SHOOT_SOUND
	sound.autoplay = true
	add_child(sound)
	sound.finished.connect(sound.queue_free)

func take_damage():
	print("玩家受傷！")  # 之後可改成扣血、重生等
	get_tree().reload_current_scene()  # 重啟關卡
