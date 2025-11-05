extends Node3D

var target_position = position
var target_rotation = rotation

var time=0.0

#stupid rotation tricks
func _process(delta):
	#target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	target_rotation.x += (cos(time * 4) * 4 + sin(time*11)) * delta  # Sine movement (up and down)
	target_rotation.y += (sin(time * 5) * 4 + cos(time*13)) * delta  # Sine movement (up and down)
	target_rotation.z += (-cos(time * 6) * 4 + sin(time*12)) * delta  # Sine movement (up and down)
	
	time += delta
	
	#position = target_position
	rotation = target_rotation
