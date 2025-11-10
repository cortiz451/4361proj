extends Area3D

@export var DMG=200
@export var SPD=20

func _on_rocket_exploded(t) -> void:
	position=t
	monitoring=true
	

func _on_body_entered(body: Node3D) -> void:
	if(body.has_method("action_shoot")):
		body.velocity.y=SPD
		#body.damage(randi_range(0,2))
	else:
		$Boom.play()
		$BoomAudio.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	if(area.has_method("damage")):
		area.damage(DMG)
	$Boom.play()
	$BoomAudio.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()
