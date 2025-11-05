extends CanvasLayer

var displayAmmo = true

var time=0.0
var lastupdate=0.0
var enemies=0

func _process(delta):
	time+=delta
	
	$FPS.text= "FPS " + str(Engine.get_frames_per_second())

func _on_health_updated(health):
	$Health.text = "Health: "+ str(health) + "%"
	
	if(health>100):
		$face_wow.visible=true
	elif(health>50):
		$face_wow.visible=false
		$face_good.visible=true
	elif(health>25):
		$face_good.visible=false
		$face_ok.visible=true
	else:
		$face_ok.visible=false
		$face_bad.visible=true

func _on_player_ammo_updated(weaponammo, type) -> void:
	if(displayAmmo):
		$Ammo.text = type+": "+str(weaponammo)
	else:
		$Ammo.text = ""

func _on_player_drain_updated(weapondrain) -> void:
	displayAmmo=(weapondrain!=0)

func _on_player_coins_updated(coins) -> void:
	$Coins.text = "Coins: "+str(coins)

func _on_enemy_down(v):
	enemies+=v
	$Enemies.text = "Enemies: "+str(enemies)
