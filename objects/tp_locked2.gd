extends Area3D

@export var dest: Marker3D

var unlocked=false

signal console_text

#teleport player
func _on_body_entered(body: Node3D) -> void:
	if(unlocked):
		body.position=dest.position
		Audio.play("sounds/tp.ogg")
	else:
		console_text.emit("Haven't unlocked that yet...")
		Audio.play("sounds/nope.ogg")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("keyGet")):
		console_text.emit("Teleport unlocked! Hopefully you won't need it...")
		unlocked=true
		$AnimatedSprite3D.animation="default"
