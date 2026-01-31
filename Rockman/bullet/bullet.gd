extends Area2D

const SPEED = 600
const SCALE = 10.0
const MAX_POWER = 20.0

var velocity = Vector2.ZERO
var is_charged = false  # 新增：追蹤是否已集氣
var charge_level: float = 0.0  # 新增：接收主角集氣時間 (0~2秒)
var power: int                  # 子彈總力量值

func _ready():
	# 依集氣時間計算子彈總力量值（1~5）
	var clamped_charge = clamp(charge_level, 0.0, 2.0)
	var t = clamped_charge / 2.0
	power = 1 + int(round(t * MAX_POWER))   # 0 秒=1，2秒=5

	if charge_level >= 2.0:
		is_charged = true
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(SCALE, SCALE), 0.3)

func _process(delta):
	position += velocity * delta
	if power <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		return
	
	if body.is_in_group("enemy") and power > 0:
		if body.has_method("take_damage"):
			# 這次最多能打出的傷害不能超過剩餘力量
			var dmg = power
			var dealt = body.take_damage(dmg)  # 回傳實際扣到的血量
			power -= dealt                     # 子彈力量扣掉
		# 不 queue_free，讓子彈繼續飛
	# 如果撞到牆、地板等非 enemy，也可以選擇直接刪掉
	else:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _draw():
	var radius = 5 + charge_level * 2.5  # 根據集氣時間即時變大
	var color = Color(1, 1, 0, 0.6).lerp(Color.WHITE, 1.0 - charge_level / 2.0)
	draw_circle(Vector2.ZERO, radius, color)
