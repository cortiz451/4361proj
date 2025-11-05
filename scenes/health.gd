extends Area3D

var target_position=position
var time=0.0

#bobby
func _process(delta):
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	time += delta
	position = target_position

#healy
func _on_body_entered(body: Node3D) -> void:
	if(body.has_method("heal")):
		body.heal(50)
		
		Audio.play("sounds/yum.ogg")
		
		queue_free()
