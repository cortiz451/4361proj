extends Area3D

@export var player: Node3D
@onready var resupplytime=$Timer

func _on_timer_timeout() -> void:
	$Sprite3D.frame=0

#resupply ammo at resupplies
func _on_player_resupply(body: Node3D) -> void:
	if(body.has_method("change_weapon")):
		var weapons=body.weapons
		#don't allow constant resupplies
		if(resupplytime.get_time_left()<=0.2):
			for w in weapons:
				w.ammo=w.maxammo
			
			$Sprite3D.frame=1
			resupplytime.start(10)
			
			Audio.play("sounds/mystery.ogg")
			player.ammo_updated.emit(player.weapon.ammo) # Update ammo on HUD
