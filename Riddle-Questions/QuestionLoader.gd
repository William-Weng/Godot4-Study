extends Node

var questions: Array = []

func _ready() -> void:
	load_questions("res://data/riddle_questions.json")

func load_questions(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("找不到題庫檔案: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(text)
	
	if parse_result != OK:
		push_error("JSON 解析錯誤: %s (第 %d 行)" % [json.get_error_message(), json.get_error_line()])
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JSON 根必須是物件，不是 %s" % typeof(data))  # typeof() 印數字，用 print(typeof(data)) 看 17=Dictionary
		return

	var data_dict: Dictionary = data
	if not "questions" in data_dict:  # ✅ 用 in 運算子，更簡潔
		push_error("JSON 缺少 'questions' 欄位")
		return
		
	questions = data_dict["questions"]
	print("✅ 載入 %d 題" % questions.size())

func get_question(index: int) -> Dictionary:
	if index < 0 or index >= questions.size():
		push_error("題目索引超出範圍: %d (總 %d 題)" % [index, questions.size()])
		return {}
	return questions[index] as Dictionary
