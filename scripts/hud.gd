extends CanvasLayer

var displayAmmo = true

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
