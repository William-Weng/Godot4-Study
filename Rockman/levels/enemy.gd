extends CharacterBody2D

const SPEED = 80.0  # 減慢速度
const PATROL_RANGE = 60.0  # 左右移動距離（像素）
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var patrol_t := 0.0

@onready var sprite = $Sprite2D
@export var max_health: int = 5

var start_x: float  # 起始X位置
var direction = 1
var health: int

func _ready():
	add_to_group("enemy")
	start_x = global_position.x  # 記錄起始位置
	health = max_health  # 初始化血量

func _physics_process(delta):
	# 重力
	velocity.y += gravity * delta
	patrol_t += delta  # 用 delta 累加時間
	
	if is_on_floor():
		var offset := sin(patrol_t * 2.0) * PATROL_RANGE
		var target_x := start_x + offset
		velocity.x = (target_x - global_position.x) * SPEED * 0.1
		sprite.flip_h = velocity.x < 0
	else:
		velocity.x = 0
	
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if collider.has_method("take_damage"):
				collider.take_damage()
			break

func take_damage(amount: int = 1) -> int:
	var before = health
	health -= amount
	if health <= 0:
		die()
	return min(amount, before)  # 實際扣到的血量

func die() -> void:
	queue_free()
