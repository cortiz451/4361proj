extends Node3D

@export var STRENGTH=40

func _on_body_entered(body: Node3D) -> void:
	Audio.play("sounds/whee.ogg")
	#player :)
	if(body.has_method("unlockWeapon")):
		body.gravity=-STRENGTH
