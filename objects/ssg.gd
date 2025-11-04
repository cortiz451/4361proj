extends Node3D

@export var Jingle: AudioStreamPlayer

var target_position: Vector3
var target_rotation: Vector3
var time = 0.0

var unlock = 2

func _process(delta):
	target_position.y += (cos(time * 5 + unlock) * 1) * delta  # Sine movement (up and down)
	target_rotation.y += delta  # Sine movement (up and down)
	time += delta
	position = target_position
	rotation = target_rotation

#unlock weapon if player touches
func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.has_method("unlockWeapon")):
		body.unlockWeapon(unlock)
		Jingle.play()
		queue_free()
	
