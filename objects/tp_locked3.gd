extends Area3D

@export var dest: Marker3D
@export var player: Node3D

var unlocked=false

signal console_text

#teleport player
func _on_body_entered(body: Node3D) -> void:
	if(unlocked):
		body.position=dest.position
		Audio.play("sounds/tp.ogg")
	else:
		console_text.emit("...?")
		Audio.play("sounds/nope.ogg")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		console_text.emit("??")
		$"../../../../JingleUnlock".play()
		unlocked=true
		#threads
		body.bossSecretTpUnlocked()
		
		$Area3D.queue_free()

func _on_player_btps_updated() -> void:
	console_text.emit("??")
	$"../../../../JingleUnlock".play()
	unlocked=true
	$Area3D.queue_free()
