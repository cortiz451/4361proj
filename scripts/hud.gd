extends CanvasLayer

var displayAmmo = true

func _on_health_updated(health):
	$Health.text = "Health: "+ str(health) + "%"

func _on_player_ammo_updated(weaponammo, type) -> void:
	if(displayAmmo):
		$Ammo.text = type+": "+str(weaponammo)
	else:
		$Ammo.text = ""

func _on_player_drain_updated(weapondrain) -> void:
	displayAmmo=(weapondrain!=0)

func _on_player_coins_updated(coins) -> void:
	$Coins.text = "Coins: "+str(coins)
