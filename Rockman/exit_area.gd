extends Area2D

@export var next_scene_path: String = "res://levels/level-2.tscn"

func _ready():
	body_entered.connect(_on_body_entered)
	# 設定碰撞遮罩匹配玩家層級（預設 Layer 1）
	collision_layer = 0
	collision_mask = 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(next_scene_path)
