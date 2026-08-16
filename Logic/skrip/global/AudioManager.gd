extends Node

var bgm_player: AudioStreamPlayer
var bgm_volume_linear: float = 1.0
var sfx_volume_linear: float = 1.0
const CLICK_SFX:AudioStream = preload("res://Asset/Audio/sfx/WAV/UI SFX_EXTRA_Start Button.wav")
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
	bgm_player.volume_db = linear_to_db(bgm_volume_linear) + volume_db
	bgm_player.play()

func set_bgm_volume(linear_vol: float):
	bgm_volume_linear = clamp(linear_vol, 0.0, 1.0)
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume_linear)

func stop_bgm():
	bgm_player.stop()

func play_sfx(stream: AudioStream=CLICK_SFX, volume_db: float = 0.0):
	if not stream:
		return
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(sfx_volume_linear) + volume_db
	sfx_player.bus = "Master"
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)

func set_sfx_volume(linear_vol: float):
	sfx_volume_linear = clamp(linear_vol, 0.0, 1.0)
