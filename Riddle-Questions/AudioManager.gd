extends Node

var bgm_player: AudioStreamPlayer

func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player, false, Node.INTERNAL_MODE_DISABLED)  # ✅ 正確參數
	bgm_player.name = "BGMPlayer"
	
	bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS  # 永遠運行
	bgm_player.volume_db = -8
	print("AudioManager 就緒")

func play_bgm(path: String) -> void:
	var stream = load(path) as AudioStream
	if stream:
		if bgm_player.stream != stream:
			bgm_player.stream = stream
		if not bgm_player.playing:
			bgm_player.play()
		print("♪ BGM 播放: ", path)
	else:
		push_error("❌ BGM 載入失敗: %s" % path)

func stop_bgm() -> void:
	bgm_player.stop()
