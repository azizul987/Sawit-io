extends Node

var bgm_player: AudioStreamPlayer

func _ready():
	# Memutar BGM tetap menyala saat pindah scene
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)

func play_bgm(stream: AudioStream, volume_db: float = 0.0):
	if bgm_player.stream == stream and bgm_player.playing:
		return # Jangan ulangi lagu yang sama
		
	bgm_player.stream = stream
	bgm_player.volume_db = volume_db
	bgm_player.play()

func stop_bgm():
	bgm_player.stop()
