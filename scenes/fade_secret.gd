extends Node

var credits="res://maaacks_template/scenes/end_credits/end_credits_wrong.tscn"
@onready var hudfade=$"../HUD/Fade"

var i=0.0


func _on_timer_timeout() -> void:
	if(i<20):
		hudfade.color=Color(0,0,0,i/20.0)
		$"../BackgroundMusicPlayer".volume_db-=1.0
		i+=1.0


func _on_end_game_end() -> void:
	#so you don't die :)
	$"../Player".sethp(999)
	
	$Timer.start(0.25)
	
	await get_tree().create_timer(5).timeout
	
	SceneLoader.load_scene(credits)
