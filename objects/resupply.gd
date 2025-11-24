extends Area3D

@export var player: Node3D
@export var wait: int = 10
@onready var resupplytime=$Timer

signal console_text

func _on_timer_timeout() -> void:
	$Sprite3D.frame=0

#resupply ammo at resupplies
func _on_player_resupply(body: Node3D) -> void:
	if(body.has_method("setAmmo")):
		#don't allow constant resupplies
		if(resupplytime.get_time_left()<=0.2):
			
			for w in body.numATypes:
				body.setAmmo(w, body.maxAmmo[w])
			
			$Sprite3D.frame=1
			resupplytime.start(wait)
			
			console_text.emit("You filled up on ammo! Now to find the baddies...")
			
			Audio.play("sounds/mystery.ogg")
			body.refreshAmmoHUD() # Update ammo on HUD
