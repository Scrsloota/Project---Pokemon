extends AudioStreamPlayer

signal smooth_audio_complete
var smooth_audio_playing: bool = false
var smooth_audio_played_time: float = 0.0


const common_path = "res://assets/audio/bgm/"

# DMC
## battle
const silver_bullet = "Silver_Bullet.mp3"
const abyssal_time = "Abyssal_Time.mp3"
const undeniable_fate = "Undeniable_Fate.mp3"
const Voltaic_Black_Knight = "Voltaic_Black_Knight.mp3"

## victory
const special_music_outro = "Special_Music_Outro.mp3"
## Town
const any_special_orders = "Any_Special_Orders.mp3"

# ACG
const Dont_say_lazy = "Don't_say_lazy.mp3"
const JOJO = "JOJO.mp3"
const il_vento_doro = "il_vento_doro.mp3"
const Judgment_Knights_of_Thunder = "Judgment_Knights_of_Thunder.mp3"
const Prove_of_honor = "Prove_of_honor.mp3"
const KING = "KING.mp3"

# AzurLane
const Fox = "Fox.mp3"
const Freedom = "Freedom.mp3"
const SAKURA_EMPIRE = "SAKURA_EMPIRE.mp3"
const TheLastStand = "TheLastStand.mp3"
const FightBack = "FightBack.mp3"
const Liyue = "Liyue.mp3"
const Victory = "Victory.mp3"


const battle_theme_presets = [
	# acg
	[ Dont_say_lazy, JOJO, il_vento_doro, KING],
	# dmc
	[silver_bullet, abyssal_time, undeniable_fate, Voltaic_Black_Knight],
	# placeholder
	[Fox, Freedom, SAKURA_EMPIRE, TheLastStand, FightBack],
]

const victory_theme_preset = [
	[Judgment_Knights_of_Thunder],
	# dmc
	[special_music_outro],
	[Victory],
]

const town_theme_preset = [
	[Prove_of_honor],
	# dmc
	[any_special_orders],
	[Liyue],
]

const smooth_seconds = 1
const segment = 50
const start_db = -20.0
const end_db = 0.0
var smooth_is_inc: bool = true
#const inter = smooth_seconds / segment
#const inc_db = - start_db / segment
#const dec_db =   start_db / segment

var battle_theme_list = battle_theme_presets[1]
var victory_theme_list = victory_theme_preset[1]
var town_theme_list = town_theme_preset[1]

func change_preset(index):
	battle_theme_list = battle_theme_presets[index]
	victory_theme_list = victory_theme_preset[index]
	town_theme_list = town_theme_preset[index]
	
	play_town_theme()

func play_battle_theme():
	yield(smooth_stop(),"completed")
	stream = load(common_path + battle_theme_list[randi() % len(battle_theme_list)])
	yield(smooth_play(),"completed")

func play_victory_fanfare():
	yield(smooth_stop(),"completed")
	stream = load(common_path + victory_theme_list[randi() % len(victory_theme_list)])
	yield(smooth_play(),"completed")
	
func play_town_theme():
	yield(smooth_stop(),"completed")
	stream = load(common_path + town_theme_list[randi() % len(town_theme_list)])
	yield(smooth_play(),"completed")
	
func smooth_play():
	volume_db = start_db
	play()
	smooth_audio_played_time = 0.0
	smooth_is_inc = true
	smooth_audio_playing = true
	yield(self, "smooth_audio_complete")
	volume_db = 0
		
func smooth_stop():
	volume_db = 0.0
	smooth_audio_played_time = 0.0
	smooth_is_inc = false
	smooth_audio_playing = true
	yield(self, "smooth_audio_complete")
	stop()
	
func _process(delta):
	if smooth_audio_playing:
		smooth_audio_played_time += delta
		if smooth_is_inc:
			volume_db = range_lerp(smooth_audio_played_time, 0.0, smooth_seconds, start_db, end_db)
		else:
			volume_db = range_lerp(smooth_audio_played_time, 0.0, smooth_seconds, end_db, start_db)
				
		if smooth_audio_played_time >= smooth_seconds:
			smooth_audio_playing = false
			smooth_audio_played_time = 0.0
			emit_signal("smooth_audio_complete")
			
