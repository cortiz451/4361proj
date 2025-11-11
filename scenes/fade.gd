extends Node

var credits="res://maaacks_template/scenes/end_credits/end_credits.tscn"
@onready var hudfade=$"../HUD/Fade"

var i=0.0

func _on_boss_end_game() -> void:
	
	#so you don't die :)
	$"../Player".sethp(999)
	
	$Timer.start(0.25)
	
	await get_tree().create_timer(15).timeout
	
	SceneLoader.load_scene(credits)


func _on_timer_timeout() -> void:
	if(i<60):
		hudfade.color=Color(0,0,0,i/60.0)
		$"../BossMusicPlayer".volume_db-=1.5
		i+=1.0


func _on_boss_music() -> void:
	$"../BackgroundMusicPlayer".stop()
	$"../BossMusicPlayer".play()
