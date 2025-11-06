extends Node3D

var target_position = position
var target_rotation = rotation

var time=0.0

#stupid rotation tricks
func _process(delta):
	#target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	target_rotation.x += (cos(time * 0.4) * 4 + sin(time*0.25)) * delta  # movement
	target_rotation.y += (sin(time * 0.5) * 4 + cos(time*0.2)) * delta  # movement
	target_rotation.z += (-cos(time * 6) * 4 + sin(time*0.1)) * delta  # movement
	
	time += delta
	
	#position = target_position
	rotation = target_rotation
