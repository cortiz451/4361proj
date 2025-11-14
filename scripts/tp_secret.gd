extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if(body.has_method("heal")):
		SceneLoader.load_scene("res://maaacks_template/scenes/game_scene/game_ui_secret.tscn")
