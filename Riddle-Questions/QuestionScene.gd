extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var image_left: TextureRect = $VBoxContainer/HBoxContainer/LeftBox/LeftImage
@onready var image_right: TextureRect = $VBoxContainer/HBoxContainer/RightBox/RightImage
@onready var prompt_label: Label = $VBoxContainer/PromptLabel
@onready var input_edit: LineEdit = $VBoxContainer/InputEdit
@onready var submit_btn: Button = $VBoxContainer/SubmitButton
@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var next_btn: Button = $VBoxContainer/NextButton  # 調整路徑

var current_question: Dictionary = {}
var current_index: int = 0
var total_questions: int = 0

func _ready() -> void:
	
	# 假設已載入 QuestionLoader.get_question(0)
	total_questions = QuestionLoader.questions.size()
	print("QuestionLoader available: ", total_questions)
	
	# https://pixabay.com/sound-effects/search/musical/
	AudioManager.play_bgm("res://audio/bgm/quiz_theme.mp3")
	if next_btn: 
		next_btn.pressed.connect(_on_next_pressed)
		next_btn.visible = false
	
	show_question(0)
	submit_btn.pressed.connect(_on_submit_pressed)
	input_edit.text_submitted.connect(_on_text_submitted)  # Enter 送出
# ✅ 用 % 快速節點 + custom_minimum_size
	await get_tree().process_frame  # 等第一幀布局完
	
	# 設定最小尺寸（Container 會自動擴展）
	$VBoxContainer.custom_minimum_size = Vector2(400, 600)
	$VBoxContainer/HBoxContainer.custom_minimum_size = Vector2(400, 200)
	
	image_left.custom_minimum_size = Vector2(150, 150)
	image_right.custom_minimum_size = Vector2(150, 150)
	input_edit.custom_minimum_size = Vector2(100, 50)
	submit_btn.custom_minimum_size = Vector2(120, 50)
	
	# 紅色按鈕樣式
	var red_style := StyleBoxFlat.new()
	red_style.bg_color = Color(1, 0.2, 0.2, 0.9)
	red_style.corner_radius_top_left = 12
	red_style.corner_radius_top_right = 12
	red_style.corner_radius_bottom_right = 12
	red_style.corner_radius_bottom_left = 12
	submit_btn.add_theme_stylebox_override("normal", red_style)
	submit_btn.add_theme_stylebox_override("hover", red_style)
	submit_btn.add_theme_stylebox_override("pressed", red_style)
	
	# 置中 + 字體放大
	$VBoxContainer.anchors_preset = Control.PRESET_CENTER
	prompt_label.add_theme_font_size_override("font_size", 28)
	result_label.add_theme_font_size_override("font_size", 24)
	
	# 自動縮放
	get_viewport().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_viewport().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

func show_question(index: int) -> void:
	current_question = QuestionLoader.get_question(index)
	if current_question.is_empty():
		result_label.text = "遊戲結束！"
		return

	title_label.text = current_question.get("title", "諧音梗遊戲")
	prompt_label.text = current_question.get("prompt", "這是＿＿＿")

	# 載入雙圖片
	var left_path = str(current_question.get("left_image", ""))
	image_left.texture = load(left_path) if left_path != "" else null

	var right_path = str(current_question.get("right_image", ""))
	image_right.texture = load(right_path) if right_path != "" else null

	# 重置
	input_edit.text = ""
	input_edit.max_length = 3  # 限三字
	result_label.text = ""
	input_edit.grab_focus()  # 自動選取輸入框

func _on_submit_pressed() -> void:
	check_answer()

func _on_text_submitted(_text: String) -> void:
	check_answer()

func check_answer() -> void:
	var user_ans := input_edit.text.strip_edges().to_upper()
	var correct := str(current_question.get("answer", "")).strip_edges().to_upper()

	if user_ans == correct:
		result_label.text = "🎉 答對了！ 正解：%s" % current_question.get("answer")
		result_label.add_theme_color_override("font_color", Color.GREEN)
		
		var tween := create_tween()
		tween.tween_property(submit_btn, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(submit_btn, "scale", Vector2(1, 1), 0.1)
		
		input_edit.editable = false
	else:
		result_label.text = "❌ 錯了～ 正解：%s\n提示：%s" % [current_question.get("answer"), current_question.get("hint", "")]
		result_label.add_theme_color_override("font_color", Color.RED)

	input_edit.editable = false  # 鎖定輸入，等下一題
	next_btn.visible = true

	# 加個 NextButton 連到下一題

func _on_next_pressed() -> void:
	
	print("下一題: %d/%d" % [current_index + 1, total_questions])
	
	current_index += 1
	
	if current_index >= total_questions:
		result_label.text = "🎉 全對完畢！"
		next_btn.visible = false
		submit_btn.visible = false
		return
	
	show_question(current_index)
	next_btn.visible = false  # 送出前隱藏
	input_edit.editable = true
