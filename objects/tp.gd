extends Area3D

@export var dest: Marker3D

#teleport player
func _on_body_entered(body: Node3D) -> void:
	body.position=dest.position
	Audio.play("sounds/tp.ogg")
