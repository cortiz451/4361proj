extends Node3D

@export var key=""
signal consoletext

func _on_warning_body_entered(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		if(body.hasKey(key)):
			body.keyUse(key)
			Audio.play("sounds/keyuse.ogg")
			queue_free()
		else:
			consoletext.emit("I need a key...")
			Audio.play("sounds/nope.ogg")
