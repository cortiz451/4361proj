extends Node

var credits="res://maaacks_template/scenes/end_credits/end_credits.tscn"
@onready var hudfade=$"../HUD/Fade"

var i=0.0

func _on_boss_end_game() -> void:
	
	#so you don't die :)
	$"../Player".sethp(999)
	
	$Timer.start(0.5)
	
	await get_tree().create_timer(5).timeout
	
	SceneLoader.load_scene(credits)


func _on_timer_timeout() -> void:
	if(i<10):
		hudfade.color=Color(0,0,0,i/9.0)
		$"../BossMusicPlayer".volume_db-=5.0
		i+=1.0


func _on_boss_music() -> void:
	$"../BackgroundMusicPlayer".stop()
	$"../BossMusicPlayer".play()
