extends Area3D

#add a coin congrats!
func _on_body_entered(body: Node3D) -> void:
	if body.has_method("coin_get"):
		Audio.play("sounds/coin.ogg")
		body.coin_get()
		queue_free()
	
