extends Node3D

var time=0.0
@onready var target_position=$Sprite3D.position

signal end

func _process(delta):
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	time += delta
	$Sprite3D.position = target_position

func _on_end(body: Node3D) -> void:
	if(body.has_method("heal")):
		end.emit()
		queue_free()
