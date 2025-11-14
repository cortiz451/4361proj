extends Area3D

@export var dest : Marker3D

func _on_body_entered(body: Node3D) -> void:
	body.position=dest.position
	Audio.play("sounds/tp.ogg")
