extends CanvasLayer

var displayAmmo = true

func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _on_player_ammo_updated(weaponammo) -> void:
	if(displayAmmo):
		$Ammo.text = str(weaponammo)
	else:
		$Ammo.text = "Hello"


func _on_player_drain_update(weapondrain) -> void:
	displayAmmo=(weapondrain!=0)
