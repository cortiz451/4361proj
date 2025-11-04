extends Area3D

#add a coin congrats!
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("coin_get"):
		body.coin_get()
	
