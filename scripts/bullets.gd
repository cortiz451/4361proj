extends Area3D

var target_position=position
var time=0.0

#bobby
func _process(delta):
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	time += delta
	position = target_position


#add a [ammo] congrats!
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("setAmmo"):
		Audio.play("sounds/ammo_get.ogg")
		#add x bullets; add=true
		body.setAmmo(2, 128, true)
		queue_free()
