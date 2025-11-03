extends CanvasLayer


func _on_health_updated(health):
	$Health.text = str(health) + "%"
	
func _on_ammo_updated(weapon):
	$Ammo.text = str(weapon.ammo)
	
