extends Node3D

signal consoletext

func _on_warning_body_entered(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		consoletext.emit("I need a key...")
		Audio.play("sounds/nope.ogg")
