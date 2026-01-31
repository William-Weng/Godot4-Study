# AnimatedCircle.gd
extends Node2D

@export var max_radius: float = 60.0
var charge_time: float = 0.0

func _draw():
	
	var radius = charge_time / 2.0 * max_radius  # 0~2秒 → 0~60px
	var pulse = sin(Time.get_unix_time_from_system() * 4) * 0.3 + 0.7  # 輕微脈動
	radius *= pulse
	
	# 內層（較亮）
	draw_circle(Vector2.ZERO, radius * 0.7, Color(1, 1, 0.8, 0.5 * (charge_time / 2.0) * pulse))
	
	# 外層（較淡）
	draw_circle(Vector2.ZERO, radius, Color(1, 0.8, 0.3, 0.2 * (charge_time / 2.0) * pulse))
	
	# 邊框
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, Color(1, 1, 0, 0.9 * (charge_time / 2.0)), 2.5)

func _process(_delta):
	queue_redraw()  # 每幀重繪

# 由主角呼叫更新集氣值
func update_charge(charge: float):
	charge_time = charge
